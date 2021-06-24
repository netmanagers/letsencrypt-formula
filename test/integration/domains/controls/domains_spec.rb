# frozen_string_literal: true

%w[
  cert
  chain
  fullchain
  privkey
].each do |f|
  describe file("/etc/letsencrypt/archive/www/#{f}1.pem") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable }
    its('size') { should be > 1 }
  end

  describe file("/etc/letsencrypt/live/www/#{f}.pem") do
    it { should be_symlink }
  end
end
describe file('/etc/letsencrypt/live/www/fullchain-privkey.pem') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }
  its('size') { should be > 1 }
end
