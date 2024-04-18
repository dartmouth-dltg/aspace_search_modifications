class AspaceSearchModHelpers
  def self.find_as_version
    version = File.join(*[ ASUtils.find_base_directory, 'ARCHIVESSPACE_VERSION'])
    return normalize_as_version(File.read(version).chomp) if File.file? version

    return 'use_method'
  end

  def self.normalize_as_version(version)
    version_num = version.gsub('v','').nil? ? 3.1 : version.gsub('v','').to_f
    case version_num
    when 3.1...3.4
      return 'pre'
    else
      return 'post'
    end
  end
end