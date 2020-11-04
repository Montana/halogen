module Halogen
  # Stores instructions for how to render a value for a given representer
  # instance
  #
  class Definition
    attr_reader :name, :options

    attr_accessor :procedure

    # Construct a new Definition instance
    #
    # @param name [Symbol, String] definition name
    # @param options [Hash] hash of options
    #
    # @return [Halogen::Definition] the instance
    #
    def initialize(name, options, procedure)
      @name      = name.to_sym
      @options   = Halogen::HashUtil.symbolize_keys!(options)
      @procedure = procedure
    end

    # @param instance [Object] the representer instance with which to evaluate
    #   the stored procedure
    #
    def value(instance)
      options.fetch(:value) do
        procedure ? instance.instance_eval(&procedure) : instance.send(name)
      end
    end

    # @return [true, false] whether this definition should be included based on
    #   its conditional guard, if any
    #
    def enabled?(instance)
      if options.key?(:if)
        !!eval_guard(instance, options.fetch(:if))
      elsif options.key?(:unless)
        !eval_guard(instance, options.fetch(:unless))
      else
        true
      end
    end

    # @return [true] if nothing is raised
    #
    # @raise [Halogen::InvalidDefinition] if the definition is invalid
    #
    def validate
      return true unless options.key?(:value) && procedure

      fail InvalidDefinition,
           "Cannot specify both value and procedure for #{name}"
    end

    private

    # Evaluate guard procedure or method
    #
    def eval_guard(instance, guard)
      case guard
      when Proc
        instance.instance_eval(&guard)
      when Symbol, String
        instance.send(guard)
      else
        guard
      end
    end
  end
end
