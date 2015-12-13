
require "pathname"

# Minimalistic <tt>DT.p</tt> implementation. Features:
#
# 1. As simple as possible.
# 2. Must suit any kind of project, including tiny console projects.
#
# Sub-features:
#
# * No dependencies other than built-in Ruby libs. Minimum of those, too.
# * Strictly 1-file implementation (plus 1 file spec, if any).
# * Compatible with Ruby 1.9 and up.
#
# Example:
#
#   require "dt"
#
#   DT.p "at control point 1"
#   DT.p "users", users
#
# @see Instance#p
module DT
  class Instance
    attr_writer :conf

    class Config
      # Root of the project, where <tt>Gemfile</tt> lives.
      attr_writer :root_path

      def root_path
        # Assume we're in `lib/dt.rb`. Or discover root path (code can be added later).
        @root_path ||= Pathname(File.expand_path("../..", __FILE__))
      end

      def initialize(attrs = {})
        attrs.each {|k, v| send("#{k}=", v)}
      end
    end # Config

    # Access the configuration object, class {DT::Instance::Config}.
    def conf
      @conf ||= Config.new
    end

    # Actual implementation of <tt>p</tt>. Caller argument is mandatory.
    def p(args, caller)
      file, line = caller[0].split(":")
      file_rel = begin
        Pathname(file).relative_path_from(conf.root_path)
      rescue ArgumentError
        # If `file` is "" or other non-path, `relative_path_from` will raise an error.
        # Fall back to original value then.
        file
      end

      args.each do |arg|
        value = case arg
        when String
          arg
        else
          arg.inspect
        end

        STDERR.puts "[DT #{file_rel}:#{line}] #{value}"
      end

      # Be like `puts`.
      nil
    end
  end # Instance

  # Access the configuration object.
  #
  # @see Instance#conf
  def self.conf
    instance.conf
  end

  # Print a debug message, dump values etc.
  #
  #   DT.p "at control point 1"
  #   DT.p "user", user
  def self.p(*args)
    instance.p(args, caller)
  end

  class << self
    private

    def instance
      @instance ||= Instance.new
    end
  end
end
