class CreateBankHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_holidays do |t|
      t.references      :area, foreign_key: true
      t.date            :holiday_date
      t.text            :title
      t.text            :notes
    end
  end
end
