module ForemanMaintain
  module Cli
    class UpgradeCommand < Base
      def self.disable_self_upgrade_option
        option '--disable-self-upgrade', :flag, 'Disable automatic self upgrade',
          :default => false
      end

      def upgrade_runner
        return @upgrade_runner if defined? @upgrade_runner
        @upgrade_runner = ForemanMaintain::UpgradeRunner.new(reporter,
          :assumeyes => assumeyes?,
          :whitelist => whitelist || [],
          :force => force?).tap(&:load)
      end

      def allow_self_upgrade?
        !disable_self_upgrade?
      end

      subcommand 'check', 'Run pre-upgrade checks before upgrading' do
        interactive_option
        disable_self_upgrade_option

        def execute
          ForemanMaintain.validate_downstream_packages
          ForemanMaintain.perform_self_upgrade if allow_self_upgrade?
          upgrade_runner.run_phase(:pre_upgrade_checks)
          exit upgrade_runner.exit_code
        end
      end

      subcommand 'run', 'Run upgrade' do
        interactive_option
        disable_self_upgrade_option

        option '--phase', 'phase', 'run only a specific phase', :required => false do |phase|
          unless UpgradeRunner::PHASES.include?(phase.to_sym)
            raise Error::UsageError, "Unknown phase #{phase}"
          end
          phase
        end

        def execute
          ForemanMaintain.validate_downstream_packages
          ForemanMaintain.perform_self_upgrade if allow_self_upgrade?
          if phase
            upgrade_runner.run_phase(phase.to_sym)
          else
            upgrade_runner.run
          end
          upgrade_runner.save
          exit upgrade_runner.exit_code
        end
      end
    end
  end
end
