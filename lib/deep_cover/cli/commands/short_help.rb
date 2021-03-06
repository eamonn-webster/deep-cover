# frozen_string_literal: true

module DeepCover
  class CLI
    desc 'short-help', 'Display a short help. Same as just `deep-cover`'
    def short_help
      self.class.short_help(shell)
    end

    def self.short_help(shell)
      list = printable_commands(true, false)
      Thor::Util.thor_classes_in(self).each do |klass|
        list += klass.printable_commands(false)
      end

      main_commands, _ignored = Tools.extract_commands_for_help(list, :exec, :clone)

      shell.say 'Main commands:'
      shell.print_table(main_commands, indent: 2, truncate: true)

      shell.say
      shell.say 'More commands:'
      shell.say '  deep-cover help [COMMAND]  # Full help with a list of lower-level commands and all options'
    end
  end
end
