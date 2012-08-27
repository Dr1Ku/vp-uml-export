# Main namespace
module VisualParadigmExcel

	# Data-related Class, parses a given Visual Paradigm-exported
	# Class Diagram and returns the 'artifacts' contained within
	# e.g. the Diagram's name and its raw components (classes,
	# attributes, associations etc.)
	class Reader 

		# External requires
		require "win32ole"

		# Internal requires
		require "./model/artifact"
		require "./model/diagram"

		# Constructor, initializes the attributes.
		# @param [String] p_sheet_path A path to the .xls file to read out of
		# @raise [RuntimeError] Argument exception when the file wasn't found
    #noinspection RubyResolve
    def initialize(p_sheet_path)

			# Check parameters
			raise RuntimeError.new("No such file ('#{p_sheet_path}')!") unless File.exists?(p_sheet_path)

			# Initialize instance variables
			@excel  = WIN32OLE::new("Excel.Application")
			@sheet = @excel.Workbooks.Open(p_sheet_path).Worksheets(1)
			@headers = []

			# Setup first and last columns, as well as the headers
			init_headers_and_bounds

			# Initialize constants
			@constants = {
                      worthy_headers: ["ArtifactType",
                                      "ID", "Name", "Type", "Model ID",
																			"Visibility", "Abstract",
																			"Multiplicity", "Scope",
																			"From", "From Multiplicity", "From Aggregation Kind",
																			"To", "To Multiplicity", "To Aggregation Kind",
                                      "General", "Specific",
																			"Parent ID"],

											diagram_name_cell: "C2",
											meta_column_name: "ArtifactType"

									 }.freeze
		end

		# Public method which fetches the given data from the Excel file,
		# according to the defined 'worthy headers' (see @@constants in
		# #initialize).
		# @returns [Hash] A hash with the :name of the Diagram and its :artifacts
    #noinspection RubyResolve
    def get_diagram_data

			# Get the diagram's name and data
			diagram_name = @sheet.Range(@constants[:diagram_name_cell]).Value
      diagram_artifacats = parse_artifacts

			# Return the result
			{ name: diagram_name, artifacts: diagram_artifacats }
    end

    # Cleanup method
    #noinspection RubyResolve
    def perform_cleanup

      # Close Excel Workbook and File
      @excel.ActiveWorkbook.Close(0)
      @excel.Quit()
    end

		private

			# Utility method, returns a list of methods
			# which can be applied to the {WIN32OLE} object
			# passed as a param.
      #noinspection RubyResolve
      def ole_methods(p_obj)
				return unless p_obj.is_a?(WIN32OLE)
				p_obj.ole_methods.collect!{ |e| e.to_s }.sort
			end

			# Helper method, returns the value of a given
			# passed Range. The passed Range can be generated
			# using #build_range.
			# @param [String] p_range The range, e.g. "A23:PO2"
      #noinspection RubyResolve
      def get_range(p_range)
				@sheet.Range(p_range).Value.flatten
			end

			# Helper method, returns an Excel-formatted Range ($R$C:$R$C)
			# which corresponds to the passed parameters.
			# @param [Hash] p_first The first component of the range, keys are :column and :row
			# @param [Hash] p_last The last component of the range, keys are :column and :row
			def build_range(p_first, p_last)
				"#{p_first[:column]}#{p_first[:row]}:#{p_last[:column]}#{p_last[:row]}"
			end

			# Helper method, initializes the available headers, by using
			# the standard first letter and index (presumably A and 1
			# respectively, see below to adjust).
			def init_headers_and_bounds

				# Store the first value here, restore it later
				first_column = "A"
				first_column_idx = "1"

				# Initialize values
				@first_column = first_column.dup
				@last_column = nil

				# Retrieve all content-filled columns
				while true do

					# Get the column's value, break if nil
					column = @sheet.Range(@first_column + first_column_idx).value
					break if column.nil?

					# Add headers to collection
					@headers << column

					# Store the value of the previous column, increase column ("A2", "A3" .. "BA" etc.)
					@last_column = @first_column.dup
					@first_column.succ!
				end

				# Restore initial value
				@first_column = first_column
			end

			# Data access method, returns a header-indexed hash representation
			# of all the cells in a given row. The row is expected to be passed
			# @param [Array] p_row_values A row's values, which will be associated with a header
			# @return [Hash] A Hash representation of the current cell
			def get_row_data(p_row_values)

				# Prepare data hash for the current row, loop through
				# the headers to associate the current row's data with the headers
				row_data = {}
				@headers.each_with_index do |current_header, idx|

					# Store the value of the current header/value pair,
					# transform to ints if the case
					value = p_row_values[idx]
					value = value.to_i if value.is_a?(Float)

					# Adjust the name of the header if empty, decide if the
					# current header is of interest
					current_header = @constants[:meta_column_name] if current_header.empty?
					is_of_interest = @constants[:worthy_headers].include?(current_header)

					# Store the value in a header-indexed hash
					row_data.store(current_header, value) if is_of_interest
				end

				# Set return value
				row_data
			end

			# Data access method, returns the needed data from
			# all the non-empty rows. The rows will be indexed
			# per the available headers.
			# @return [Array] An array of row data, see #get_row_data .
			def parse_artifacts

				# Prepare result and current row
				rows_data = []
				current_row_index = 1

				# Loop over each row, gathering data
				while true do

					# Build the range according to defined limits (first, last column), current row
					current_row_index += 1
					current_range = build_range({ column: @first_column, row: current_row_index },
																			{ column: @last_column , row: current_row_index })

					# Get data on the current row, break if all values are nil
					row = get_range(current_range)
					break if row.compact.empty?

					# Get this row's data, add to result
					row_data = get_row_data(row)
					rows_data << row_data
				end

				# Return result
				rows_data
			end
			
	end

end