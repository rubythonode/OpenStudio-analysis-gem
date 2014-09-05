# Simple class to translate a JSON file into the SpreadSheet needed for the analysis
module OpenStudio
  module Analysis
    module Translator
      class JsonToSpreadsheet

        def initialize(filename)
          fail 'JSON file does not exist' unless File.exist? filename
          @json_filename = filename
        end

        def translate(save_as = nil)
          # eventually this needs to be a class/structure with accessors
          @analysis_data = JSON.parse(File.read(@json_filename), symbolize_names: true)

          # for now just call the version_1
          translate_version_1
        end

        private

        def translate_version_1
          book = RubyXL::Workbook.new
          book.add_worksheet 'output variables'
          worksheet = book[0]
          worksheet.sheet_name = 'variables'


          row_cnt = 0
          # write the header row
          worksheet.add_cell(row_cnt, 0, 'Inputs')
          worksheet.add_cell(row_cnt, 2, 'Continuous Variable Description')
          worksheet.add_cell(row_cnt, 4, 'Discrete Variable Description')
          worksheet.add_cell(row_cnt, 8, 'Other Notes')
          worksheet.change_row_fill(row_cnt, '0ba53d')

          row_cnt += 1
          worksheet.add_cell(row_cnt, 0, '# Measure Enabled')

          row_cnt += 1
          worksheet.add_cell(row_cnt, 0, '# Variable')

          @analysis_data[:analysis][:problem][:workflow].each do |wfi|
            row_cnt += 1
            worksheet.add_cell(row_cnt, 0, true)
            worksheet.add_cell(row_cnt, 1, wfi[:measure_definition_display_name])

            wfi[:variables].each do |var|
              row_cnt += 1
              worksheet.add_cell(row_cnt, 1, 'variable')
              # skip 2
              worksheet.add_cell(row_cnt, 3, var[:display_name])
            end

            wfi[:arguments].each do |arg|
              row_cnt += 1
              worksheet.add_cell(row_cnt, 1, 'argument')
              # skip 2
              worksheet.add_cell(row_cnt, 3, arg[:display_name])
            end
          end

          # set some column widths
          worksheet.change_column_width(3, 30)

          book.write 'excel-file.xlsx'

          # try reading a spreadsheet that is macro enabled!
          # This doesn't work.
          f = File.expand_path 'doc/template-macro.xlsm'
          puts f
          if File.exist?(f)
            book = RubyXL::Parser.parse f
            book.add_worksheet 'something new'
            book.write 'read-then-write.xlsm'
          else
            fail "file #{f} does not exist"
          end


        end
      end
    end
  end
end