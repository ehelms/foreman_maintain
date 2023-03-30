module ForemanMaintain
  module CoreExt
    module StripHeredoc
      def strip_heredoc
        indent = 0
        indented_lines = scan(/^[ \t]+(?=\S)/)
        unless indented_lines.empty?
          indent = indented_lines.min.size
        end
        gsub(/^[ \t]{#{indent}}/, '')
      end
    end
    String.include StripHeredoc

    module ValidateOptions
      def validate_options!(*valid_keys)
        valid_keys.flatten!
        unexpected_options = keys - valid_keys - valid_keys.map(&:to_s)
        unless unexpected_options.empty?
          raise ArgumentError, "Unexpected options #{unexpected_options.inspect}. "\
            "Valid keys are: #{valid_keys.map(&:inspect).join(', ')}"
        end
        self
      end
    end
    Hash.include ValidateOptions
  end
end
