class LogsController < ApplicationController
  before_action :set_log

  # GET /logs
  # GET /logs.json
  def index
  end

  # GET /logs/1
  # GET /logs/1.json
  def show
  end

  # GET /logs/new
  def new
    @log              = Log.new
    @log.time         = DateTime.now
    @log.log_contents = @logs;
  end

  # GET /logs/1/edit
  def edit
  end

  # POST /logs
  # POST /logs.json
  def create
    @log              = Log.new(log_params)
    @log.time         = DateTime.now
    @log.log_contents = @logs;

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: 'Log was successfully created.' }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
  def update
    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: 'Log was successfully updated.' }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to logs_url, notice: 'Log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_errors(limit = 1000, around_count = 10)
    log_file            = File.join(Rails.root, 'log', Rails.env + '.log')
    lines               = File.readlines(log_file)
    limit               = lines.length - limit
    error_lines         = []
    current_line        = 0

    while (line = lines[current_line])
      current_line     += 1

      next if current_line < limit

      if line =~ /^.*(FATAL|ERROR)\s+\-\-.*$/
        before_lines    = current_line - around_count

        while before_lines < current_line
          error_lines.push(lines[before_lines])

          before_lines += 1
        end

        error_lines.push(line)

        after_lines     = around_count

        while after_lines > 0
          error_lines.push(lines[current_line])

          current_line += 1
          after_lines  -= 1
        end
      end
    end

    error_lines
  end

  def parse_log(line)
    log        = if line =~ /^([A-Z]),\s*\[(\d{4}\-\d{2}\-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d*)\s*\#(\d+)\]\s*(ERROR|INFO|DEBUG|FATAL).*\s+\-\-\s*:\s*(.*)$/
                   @event_time = DateTime.parse(Regexp.last_match[2])
                   log_id      = Regexp.last_match[3].to_i if Regexp.last_match[3].present?

                   Log.new(:log_category => Regexp.last_match[1],
                           :error_time   => @event_time,
                           :log_id       => log_id,
                           :log_sha      => nil,
                           :log_type     => Regexp.last_match[4],
                           :log_contents => Regexp.last_match[5],
                           :raw_line     => Regexp.last_match[0])
                 elsif line =~ /^\[(.+)\]\s+(.*)/
                   Log.new(:log_category => 'S',
                           :error_time   => @event_time,
                           :log_id       => nil,
                           :log_sha      => Regexp.last_match[1],
                           :log_type     => 'UNKNOWN SHA',
                           :log_contents => Regexp.last_match[2],
                           :raw_line     => Regexp.last_match[0])
                 else
                   Log.new(:log_category => '?',
                           :error_time   => @event_time,
                           :log_id       => nil,
                           :log_sha      => nil,
                           :log_type     => 'UNKNOWN',
                           :log_contents => line,
                           :raw_line     => line)
                 end

    log
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      if params[:id].present?
        @log        = Log.find(params[:id])
      else
        @logs       = []
        @event_time = DateTime.now unless @event_time.present?
        lines       = get_errors

        lines.each do |line|
          log       = parse_log(line)

          log.save!
          @logs.push(log)
        end if lines.present?

        @log        = @logs.last
      end
    end

    # Only allow a list of trusted parameters through.
    def log_params
      params.require(
                       :log
                    ).permit(
                       :log_category,
                       :error_time,
                       :log_id,
                       :log_sha,
                       :log_type,
                       :log_contents,
                       :raw_line
                    )
    end
end
