require 'csv'
require 'date'

class Patient
  attr_accessor :first_name, :last_name, :dob, :member_id, :effective_date, :expiry_date, :phone_number
  attr_accessor :errors

  def initialize(first_name, last_name, dob, member_id, effective_date, expiry_date, phone_number)
    @errors = []

    @first_name = sanitize("first_name", first_name)
    @last_name = sanitize("last_name", last_name)
    @dob = sanitize("dob", dob, true)
    @member_id = sanitize("member_id", member_id)
    @effective_date = sanitize("effective_date", effective_date, true)
    @expiry_date = sanitize("expiry_date", expiry_date, true)
    @phone_number = sanitize("phone_number", phone_number)
  end

  def sanitize(attr, value, iso8601=false)
    if value.nil?
      @errors << ("#{attr} column is required.")
      return nil
    end

    value = value.gsub(/\s/, "")
    if value.empty?
      @errors << ("#{attr} column is required.")
      return nil
    end

    if iso8601
      if value =~ /^\d{4}-\d{1,2}-\d{1,2}$/
        value = Date.parse(value).strftime("%Y-%m-%d")
      elsif value =~ /.-./
        value = Date.strptime(value, "%m-%d-%y").strftime("%Y-%m-%d")
      else
        value = Date.strptime(value, "%m/%d/%y").strftime("%Y-%m-%d")
      end
    end

    if attr == "phone_number"
      value = value.gsub(/-/, "").delete('()')

      if value =~ /^1\d{10}$/
        return value
      elsif value =~ /^\d{10}$/
        return "1#{value}"
      else
        @errors << ("#{attr} column is not in compliance with E.164 format.")
      end
    end

    return value

  end

  def is_valid
    @errors.count == 0 ? true : false
  end

  def to_csv_row
    ["#{first_name}", "#{last_name}", "#{dob}", "#{member_id}",
    "#{effective_date}", "#{expiry_date}", "#{phone_number}"]
  end

  def to_report
    err_msg = "#{first_name} #{last_name} whose member ID is #{member_id} turns out invalid. The reasons are : \n"
    @errors.each do |msg|
      err_msg += "- #{msg}\n"
    end
    err_msg
  end

  def errors
    @errors
  end
end


class CSVHandler
  def initialize
    @filename = ARGV[0]
  end

  def read_from_csv
    table = CSV.parse(File.read(@filename, encoding: 'bom|utf-8'), headers: true, col_sep: ",")
    @patients = table.map do |row|
      Patient.new(
        row["first_name"],
        row["last_name"],
        row["dob"],
        row["member_id"],
        row["effective_date"],
        row["expiry_date"],
        row["phone_number"]
      )
    end
    p @patients.inspect
  end

  def write
    headers = ["first_name", "last_name", "dob", "member_id", "effective_date", "expiry_date", "phone_number"]


    CSV.open("output.csv", "w") do |csv|
      csv << headers
      @patients.each do |patient|
        if patient.is_valid
          csv << patient.to_csv_row()
        else
          File.open('report.txt', 'a') { |file| file.write(patient.to_report()) }
        end
      end
    end
  end
end

csv = CSVHandler.new
csv.read_from_csv()
csv.write()
