# frozen_string_literal: true

module Boondoc
  # Top-level classes and modules of Ruby core and the standard library. A
  # fixed list, because what happens to be loaded in boondoc's own process
  # (Thor, Rake, Boondoc itself) says nothing about the project being documented.
  CORE_CONSTANTS = %w[
    ArgumentError Array BasicObject Binding Class ClosedQueueError Comparable Complex ConditionVariable Data
    Dir EOFError Encoding EncodingError Enumerable Enumerator Errno Exception FalseClass Fiber FiberError File
    FileTest Float FloatDomainError FrozenError GC Hash IO IOError IndexError Integer Interrupt Kernel KeyError
    LoadError LocalJumpError Marshal MatchData Math Method Module Mutex NameError NilClass NoMatchingPatternError
    NoMatchingPatternKeyError NoMemoryError NoMethodError NotImplementedError Numeric Object ObjectSpace Pathname
    Proc Process Queue Ractor Random Range RangeError Rational Refinement Regexp RegexpError Ruby RubyVM
    RuntimeError ScriptError SecurityError Set Signal SignalException SizedQueue StandardError StopIteration String
    Struct Symbol SyntaxError SystemCallError SystemExit SystemStackError Thread ThreadError ThreadGroup Time
    TracePoint TrueClass TypeError UnboundMethod UncaughtThrowError Warning ZeroDivisionError
    Base64 Benchmark BigDecimal CGI CSV Coverage DRb Date DateTime Delegator Digest ERB Etc Fcntl Fiddle FileUtils
    Find Forwardable GetoptLong IPAddr IPSocket JSON Logger Monitor MonitorMixin Net Observable Open3 OpenSSL
    OpenStruct OptionParser PP PStore Psych Racc Readline Reline Resolv Ripper SecureRandom Shellwords
    SimpleDelegator Singleton Socket StringIO StringScanner Syslog TCPServer TCPSocket Tempfile Timeout Tmpdir
    TSort UDPSocket UNIXServer UNIXSocket URI WeakRef YAML Zlib
  ].freeze
end
