RSpec.describe RSpec::Buildkite do
  it "has a version number" do
    expect(RSpec::Buildkite::VERSION).not_to be nil
  end

  it "does something useful" do
    sleep(5)
    expect(false).to eq(true)
    sleep(5)
  end

  it "fails several times" do
    sleep(5)
    expect(false).to eq(true)
    sleep(5)
  end
end
