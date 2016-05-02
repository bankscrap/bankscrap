module Bankscrap
  class AdapterGenerator < Thor::Group
    include Thor::Actions

    argument :bank_name

    def self.source_root
       File.join(File.dirname(__FILE__), 'templates')
    end

    def generate
      self.destination_root = File.expand_path('.', gem_name)
      directory '.'

      say ""
      say "Great! Now you can start implementing your bank's adapter for Bankscrap.", :yellow
      say ""
      say "To get started take a look to:", :yellow
      say "#{destination_root}/#{gem_name}.rb", :yellow
      say ""
      say "If you need help you can join our Slack chat room. Click the Slack badge on Github:", :yellow
      say "https://github.com/bankscrap/bankscrap", :yellow
    end

    protected

    def bank_name_dasherized
      @bank_name_dasherized ||= bank_name.underscore.dasherize
    end
    def gem_name
      @gem_name ||= 'bankscrap-' + bank_name_dasherized
    end

    def module_name
      @module_name ||= bank_name
    end
  end
end