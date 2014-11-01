require 'showoff'

class ShowOff < Sinatra::Application
  alias_method :old_update_commandline_code, :update_commandline_code

  def update_commandline_code(slide)
    slide = old_update_commandline_code slide

    html = Nokogiri::HTML.parse(slide)

    html.css('pre').each do |pre|
      pre.css('code').each do |code|
        out = code.text
        lines = out.split("\n")
        lines.delete_at(lines.size-1) if lines[lines.size-1].strip == '```'
        if lines.first.strip[0, 3] == '```'
          lang = lines.shift.gsub('```', '').strip
          pre.set_attribute('class', 'sh_' + lang.downcase) if !lang.empty?
          code.content = lines.join("\n")
        end
      end
    end

    html.root.to_s
  end
end