require 'json'

module Chain
  # environment path (defaults to ~/.chain)
  CHAINPATH = ENV['CHAINPATH'] || File.join(Dir.home, ".chain")
  ENV['CHAINPATH'] ||= CHAINPATH

  # directory paths
  DOMAINS_DIR = File.join(CHAINPATH, 'domains')
  PIPELINE_DIR = File.join(CHAINPATH, 'pipelines')
  PROGRAMS_DIR = File.join(CHAINPATH, 'programs')
  APPS_DIR = File.join(CHAINPATH, 'apps')
  SCRIPTS_DIR = File.join(CHAINPATH, 'scripts')

  # files and extensions
  SETTINGS_FILE = File.join(CHAINPATH, 'settings.json')
  DOMAIN_EXT, PIPELINE_EXT, PROGRAM_EXT = '.json'

  class Settings < Hash

    def initialize
      self.setup_dirs
      self.load
      super
    end

    def setup_dirs
      # ensure all directories exist
      [CHAINPATH, DOMAINS_DIR, PIPELINE_DIR, PROGRAMS_DIR, APPS_DIR, SCRIPTS_DIR].each do |dir|
        Dir.mkdir(dir) unless Dir.exists?(dir)
      end
    end

    def load
      # load settings to SETTINGS_FILE
      self.merge(JSON.load(File.new(SETTINGS_FILE))) if File.exists?(SETTINGS_FILE)
    end

    def save
      # save settings to SETTINGS_FILE
      File.open(SETTINGS_FILE, 'w') do |sf|
        sf.write(JSON.generate(self))
      end
    end

    def restore_defaults
      # TODO
    end

    def clear
      # clear settings from memory and file
      File.delete(SETTINGS_FILE) if File.exists?(SETTINGS_FILE)
      super
    end

  end

end