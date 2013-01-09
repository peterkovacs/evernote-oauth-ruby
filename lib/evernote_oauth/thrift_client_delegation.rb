module EvernoteOAuth

  module ThriftClientDelegation
    def method_missing(name, *args, &block)
      method = @client.class.instance_method(name)
      result = if method.arity != args.size &&
	begin
	  @client.send(name, [ token ] + args, &block)
	rescue ArgumentError => e
	  puts e.inspect
	  @client.send(name, *args, &block)
	end
      else
	@client.send(name, *args, &block)
      end

      attr_name = underscore(self.class.name.split('::').last).to_sym
      attr_value = self
      [result].flatten.each{|r|
        begin
          singleton = class << r; self end
          singleton.send( :define_method, attr_name, lambda { attr_value } )
        rescue TypeError # Fixnum/TrueClass/FalseClass/NilClass
          next
        end
      }
      result
    end

    private
    def underscore(word)
      word.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end

end
