require './patient'
require 'rspec'


RSpec.describe "Patient" do
  context "with empty field" do
    it "throws an error" do
      patient = Patient.new("Antonio", "Cape", "9/2/1966", "890887", "9/30/19", "", "303-333-9987")
      expect(patient.is_valid).to eq false
    end
  end

  context "with incompatbile phone number" do
    it "is an invalid patient." do
      patient = Patient.new("Antonio", "Cape", "9/2/1966", "890887", "9/30/19", "9/30/2000", "33033339987")
      expect(patient.is_valid).to eq false
    end
  end

  context "with all the columns with good-formatted phone number" do
    it "is a valid patient." do
      patient = Patient.new("Antonio", "Cape", "9/2/1966", "890887", "9/30/19", "9/30/2000", "303-333-9987")
      expect(patient.is_valid).to eq true
    end
  end

end