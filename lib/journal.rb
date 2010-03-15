require 'yaml'

class Journal
  Medline_to_ISO = YAML.load_file(File.join(File.dirname(__FILE__), 'journal', 'medline_to_iso.yaml'))
  Medline_to_Full = YAML.load_file(File.join(File.dirname(__FILE__), 'journal', 'medline_to_full.yaml'))
end
