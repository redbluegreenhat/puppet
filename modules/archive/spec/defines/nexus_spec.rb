# frozen_string_literal: true

require 'spec_helper'

describe 'archive::nexus' do
  let(:facts) { { os: { family: 'RedHat' }, puppetversion: '4.4.0' } }

  context 'nexus archive with defaults' do
    let(:title) { '/tmp/hawtio.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war'
      }
    end

    it do
      expect(subject).to contain_archive('/tmp/hawtio.war').with(
        source: 'https://oss.sonatype.org/service/local/artifact/maven/content?g=io.hawt&a=hawtio-web&v=1.4.36&r=releases&p=war',
        checksum_url: 'https://oss.sonatype.org/service/local/artifact/maven/content?g=io.hawt&a=hawtio-web&v=1.4.36&r=releases&p=war.md5'
      )
    end

    it do
      expect(subject).to contain_file('/tmp/hawtio.war').that_requires('Archive[/tmp/hawtio.war]').with(
        owner: '0',
        group: '0'
      )
    end
  end

  context 'nexus archive with overwritten parameters' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        owner: 'tom',
        group: 'worker',
        user: 'tom',
        extract: true,
        extract_path: '/opt',
        creates: '/opt/artifact/WEB-INF',
        cleanup: true,
        temp_dir: '/tmp'
      }
    end

    it do
      expect(subject).to contain_archive('/tmp/artifact.war').with(
        'user' => 'tom',
        'group' => 'worker',
        'extract' => true,
        'extract_path' => '/opt',
        'creates' => '/opt/artifact/WEB-INF',
        'cleanup' => true,
        'temp_dir' => '/tmp'
      )
    end

    it do
      expect(subject).to contain_file('/tmp/artifact.war').that_requires('Archive[/tmp/artifact.war]').with(
        'owner' => 'tom',
        'group' => 'worker'
      )
    end
  end

  context 'nexus archive with checksum_verify => false' do
    let :title do
      '/tmp/artifact.war'
    end

    let :params do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        owner: 'tom',
        group: 'worker',
        user: 'tom',
        extract: true,
        extract_path: '/opt',
        creates: '/opt/artifact/WEB-INF',
        cleanup: true,
        checksum_verify: false
      }
    end

    it do
      expect(subject).to contain_archive('/tmp/artifact.war').with(
        'user' => 'tom',
        'group' => 'worker',
        'extract' => true,
        'extract_path' => '/opt',
        'creates' => '/opt/artifact/WEB-INF',
        'cleanup' => true,
        'checksum_verify' => false
      )
    end

    it do
      expect(subject).to contain_file('/tmp/artifact.war').that_requires('Archive[/tmp/artifact.war]').with(
        'owner' => 'tom',
        'group' => 'worker'
      )
    end
  end

  context 'nexus archive with allow_insecure => true' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war',
        allow_insecure: true
      }
    end

    it { is_expected.to contain_archive('/tmp/artifact.war').with_allow_insecure(true) }
  end

  context 'nexus archive with allow_insecure => false' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war',
        allow_insecure: false
      }
    end

    it { is_expected.to contain_archive('/tmp/artifact.war').with_allow_insecure(false) }
  end

  context 'nexus archive with allow_insecure => \'foobar\'' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war',
        allow_insecure: 'foobar'
      }
    end

    it { is_expected.to compile.and_raise_error(%r{parameter 'allow_insecure' expects a value of type Undef or Boolean, got String}) }
  end

  context 'nexus archive with use_nexus3_urls => false' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war',
        use_nexus3_urls: false
      }
    end

    it { is_expected.to contain_archive('/tmp/artifact.war').with_source('https://oss.sonatype.org/service/local/artifact/maven/content?g=io.hawt&a=hawtio-web&v=1.4.36&r=releases&p=war') }
  end

  context 'nexus archive with use_nexus3_urls => true' do
    let(:title) { '/tmp/artifact.war' }

    let(:params) do
      {
        url: 'https://oss.sonatype.org',
        gav: 'io.hawt:hawtio-web:1.4.36',
        repository: 'releases',
        packaging: 'war',
        use_nexus3_urls: true
      }
    end

    it { is_expected.to contain_archive('/tmp/artifact.war').with_source('https://oss.sonatype.org/repository/releases/io/hawt/hawtio-web/1.4.36/hawtio-web-1.4.36.war') }
  end
end
