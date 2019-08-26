# frozen_string_literal: true

require 'pronto'
require 'open3'
require 'pathname'

module Pronto
  Offence = Struct.new(
    :type, :module, :line, :column, :path, :symbol, :message, :message_id
  ) do
    def self.create_from_json(json)
      new(
        json[:type], json[:module], json[:line], json[:column], Pathname.new(json[:path]),
        json[:symbol], json[:message], json[:'message-id']
      )
    end

    def pronto_level
      case type
      when 'warning', 'error', 'fatal'
        type.to_sym
      else
        :warning
      end
    end
  end

  class Pylint < Runner
    def initialize(patches, commit = nil)
      super(patches, commit)
    end

    def run
      return [] unless python_patches

      file_args = python_patches
        .map(&:new_file_full_path)
        .join(' ')

      return [] if file_args.empty?

      stdout, stderr, = Open3.capture3("#{pylint_executable} --output-format=json #{file_args}")
      stderr.strip!

      puts "WARN: pronto-pylint:\n\n#{stderr}" unless stderr.empty?

      JSON.parse(stdout, symbolize_names: true)
        .map { |json| Offence.create_from_json(json) }
        .map { |o| [patch_line_for_offence(o), o] }
        .reject { |(line, _)| line.nil? }
        .map { |(line, offence)| create_message(line, offence) }
    end

    private

    def pylint_executable
      'pylint'
    end

    def python_patches
      @python_patches ||= @patches
        .select { |p| p.additions.positive? }
        .select { |p| p.new_file_full_path.extname == '.py' }
    end

    def patch_line_for_offence(offence)
      python_patches
        .select { |patch| patch.new_file_full_path == offence.path.expand_path }
        .flat_map(&:added_lines)
        .find { |patch_lines| patch_lines.new_lineno == offence.line }
    end

    def create_message(patch_line, offence)
      Message.new(
        offence.path.to_s,
        patch_line,
        offence.pronto_level,
        offence.message,
        nil,
        self.class
      )
    end
  end
end
