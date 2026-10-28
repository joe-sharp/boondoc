# frozen_string_literal: true

module Boondoc
  # Expands YARD reference docstrings: `(see Foo#bar)` as a whole docstring, or
  # as the text of a tag such as `@param (see Foo#bar)`.
  class References
    SEE = /\A\(see (\S+)\)\z/

    # @param registry [Model::Registry]
    def initialize(registry)
      @registry = registry
    end

    # @return [void]
    def expand
      @visited = {}.compare_by_identity
      @registry.each { |object| expand_object(object) }
    end

    private

    # Targets are expanded before they are copied, so chains such as
    # `(see B)` -> `(see C)` work in any order. A cycle stops at the object
    # already being expanded.
    def expand_object(object)
      return if @visited.key?(object)

      @visited[object] = true
      docstring = object.docstring
      tags = docstring.tags.flat_map { |tag| expand_tag(object, tag) }
      text = docstring.text
      target = referenced(object, text.strip)
      if target
        text = target.docstring.text
        tags += inherited_tags(target, tags)
      end
      object.docstring = Model::Docstring.new(text, tags, docstring.directives)
    end

    def inherited_tags(target, own_tags)
      own = own_tags.map(&:tag_name)
      target.docstring.tags.reject { |tag| own.include?(tag.tag_name) }
    end

    def expand_tag(object, tag)
      target = referenced(object, tag.text.to_s.strip)
      target ? target.docstring.tags_named(tag.tag_name) : [tag]
    end

    def referenced(object, text)
      match = SEE.match(text)
      target = match && @registry.resolve(object, match[1])
      return nil if target.nil? || target.equal?(object)

      expand_object(target)
      target
    end
  end
end
