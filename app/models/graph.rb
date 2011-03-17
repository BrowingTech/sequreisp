# Sequreisp - Copyright 2010, 2011 Luciano Ruete
#
# This file is part of Sequreisp.
#
# Sequreisp is free software: you can redistribute it and/or modify
# it under the terms of the GNU Afero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Sequreisp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Afero General Public License for more details.
#
# You should have received a copy of the GNU Afero General Public License
# along with Sequreisp.  If not, see <http://www.gnu.org/licenses/>.

class Graph
  RRD_DB_DIR=RAILS_ROOT + "/db/rrd"
  RRD_IMG_DIR=RAILS_ROOT + "/public/images/rrd"
  attr_accessor :element
  def initialize(options)
    @element = nil
    if options[:element].nil? 
      if (not options[:class].nil?) and (not options[:id].nil?)
        @element = options[:class].constantize.find options[:id]
      end 
    else
      @element = options[:element]
    end
    raise "Undefined :element or :class,:id" if @element.nil?
  end
  def name
    case element.class.to_s
    when "Contract"
      "#{element.client.name}"
    when "Provider", "ProviderGroup", "Interface"
      "#{element.name}"
    end
  end
  def img(mtime, msize)
    width = 0
    height = 0
    time = 0
    xgrid = 0
    case mtime
    when "hour"
      time = "-1h"
      xgrid = "MINUTE:10:MINUTE:30:MINUTE:30:0:\%H:\%M"
    when "day"
      time = "-1d"
      xgrid = "MINUTE:30:HOUR:1:HOUR:3:0:\%H:\%M"
    when "month"
      time = "-1m"
      xgrid = "DAY:1:DAY:7:DAY:7:0:\%d-\%b"
    when "year"
      time = "-1y"
      xgrid = "MONTH:1:MONTH:1:MONTH:1:0:\%b"
    end
    case msize 
    when "small"
      width = 150
      height = 62
      xgrid = "HOUR:6:HOUR:6:HOUR:6:0:\%Hhs"
      graph_small(time, xgrid, width, height)
    when "medium"
      width = 500
      height = 60
      graph(time, xgrid, width, height) 
    when "large"
      width = 650 
      height = 180
      graph(time, xgrid, width, height) 
    end
  end
  def path_rrd
    RRD_DB_DIR + "/#{element.class.to_s}.#{element.id}.rrd"
  end
  def path_img(gname)
    RRD_IMG_DIR + "/#{gname}.png"
  end
  def graph(time, xgrid, width, height)
    gname = "#{element.class.to_s}.#{element.id}.#{time}.#{width}.#{height}"
    case element.class.to_s
    when "Provider", "ProviderGroup", "Interface"
      RRD::Wrapper.graph!(
        path_img(gname),
        "-s", time,
        "DEF:down_prio=#{path_rrd}:down_prio:AVERAGE",
        "DEF:down_dfl=#{path_rrd}:down_dfl:AVERAGE",
        "DEF:up_prio=#{path_rrd}:up_prio:AVERAGE",
        "DEF:up_dfl=#{path_rrd}:up_dfl:AVERAGE",
        "CDEF:down_prio_=down_prio,8,*",
        "CDEF:down_dfl_=down_dfl,8,*",
        "CDEF:down_=down_prio_,down_dfl_,+",
        "CDEF:up_prio_=up_prio,8,*",
        "CDEF:up_dfl_=up_dfl,8,*",
        "CDEF:up_=up_prio_,up_dfl_,+",
        "AREA:down_prio_#00AA00:down",
        #"STACK:down_dfl_#00EE00:down p2p",
        #"GPRINT:down_:AVERAGE:\nPromedio %.2lf%sbps",
        #"GPRINT:down_prio_:AVERAGE:(prio=%.2lf%sbps",
        #"GPRINT:down_dfl_:AVERAGE:p2p=%.2lf%sbps)",
        #"COMMENT:\\n",
        "LINE1:up_prio_#FF0000:up",
        #"STACK:up_dfl_#FF6600:up p2p",
        #"GPRINT:up_:AVERAGE:Promedio %.2lf%sbps",
        #"GPRINT:up_prio_:AVERAGE:(prio=%.2lf%sbps",
        #"GPRINT:up_dfl_:AVERAGE:p2p=%.2lf%sbps)",
        #"COMMENT:\\n",
        "HRULE:#{element.rate_down*1024}#00AA0066",
        "HRULE:#{element.rate_up*1024}#FF000066",
        "--upper-limit=#{element.rate_down*1000}",
        "--vertical-label=bps(bits/second)",
        "--interlaced",
        "--watermark=SequreISP",
        "--lower-limit=0",
        "--x-grid", xgrid,
        "--alt-y-grid",
        "--width", "#{width}",
        "--height", "#{height}",
        "--imgformat", "PNG"
      ) rescue alt = "Gráfico no disponible"
    when "Contract"
      RRD::Wrapper.graph!(
        path_img(gname),
        "-s", time,
        "DEF:down_prio=#{path_rrd}:down_prio:AVERAGE",
        "DEF:down_dfl=#{path_rrd}:down_dfl:AVERAGE",
        "DEF:up_prio=#{path_rrd}:up_prio:AVERAGE",
        "DEF:up_dfl=#{path_rrd}:up_dfl:AVERAGE",
        "CDEF:down_prio_=down_prio,8,*",
        "CDEF:down_dfl_=down_dfl,8,*",
        "CDEF:down_=down_prio_,down_dfl_,+",
        "CDEF:up_prio_=up_prio,8,*",
        "CDEF:up_dfl_=up_dfl,8,*",
        "CDEF:up_=up_prio_,up_dfl_,+",
        "AREA:down_prio_#00AA00:down",
        "STACK:down_dfl_#00EE00:down p2p",
        #"GPRINT:down_:AVERAGE:\nPromedio %.2lf%sbps",
        #"GPRINT:down_prio_:AVERAGE:(prio=%.2lf%sbps",
        #"GPRINT:down_dfl_:AVERAGE:p2p=%.2lf%sbps)",
        #"COMMENT:\\n",
        "LINE1:up_prio_#FF0000:up",
        "STACK:up_dfl_#FF6600:up p2p",
        #"GPRINT:up_:AVERAGE:Promedio %.2lf%sbps",
        #"GPRINT:up_prio_:AVERAGE:(prio=%.2lf%sbps",
        #"GPRINT:up_dfl_:AVERAGE:p2p=%.2lf%sbps)",
        #"COMMENT:\\n",
        "HRULE:#{element.plan.ceil_down*1024}#00AA0066",
        "HRULE:#{element.plan.ceil_up*1024}#FF000066",
        "--upper-limit=#{element.plan.ceil_down*1000}",
        "--vertical-label=bps(bits/second)",
        "--interlaced",
        "--watermark=SequreISP",
        "--lower-limit=0",
        "--x-grid", xgrid,
        "--alt-y-grid",
        "--width", "#{width}",
        "--height", "#{height}",
        "--imgformat", "PNG"
      ) rescue alt = "Gráfico no disponible"
    end
    #"<a href=\"/graphs/#{element.id}/?class=#{element.class.to_s}\"><img src=\"/images/rrd/#{gname}.png\"></a>"
    "<img alt=\"#{alt}\" src=\"/images/rrd/#{gname}.png\">"
  end
  def graph_small(time, xgrid, width, height)
    gname = "#{element.class.to_s}.#{element.id}.#{time}.#{width}.#{height}"
    case element.class.to_s
    when "Provider", "ProviderGroup", "Interface"
      RRD::Wrapper.graph!(
        path_img(gname),
        "-s", time,
        "DEF:down_prio=#{path_rrd}:down_prio:AVERAGE",
        "DEF:down_dfl=#{path_rrd}:down_dfl:AVERAGE",
        "DEF:up_prio=#{path_rrd}:up_prio:AVERAGE",
        "DEF:up_dfl=#{path_rrd}:up_dfl:AVERAGE",
        "CDEF:down_prio_=down_prio,8,*",
        "CDEF:down_dfl_=down_dfl,8,*",
        "CDEF:up_prio_=up_prio,8,*",
        "CDEF:up_dfl_=up_dfl,8,*",
        "AREA:down_prio_#00AA00:down",
        #"STACK:down_dfl_#00EE00:down p2p",
        "LINE1:up_prio_#FF0000:up",
        #"STACK:up_dfl_#FF6600:up p2p",
        "HRULE:#{element.rate_down*1024}#00AA0066",
        "HRULE:#{element.rate_up*1024}#FF000066",
        "--upper-limit=#{element.rate_down*1000}",
        "--interlaced",
        "--lower-limit=0",
        "--x-grid", xgrid,
        "--alt-y-grid",
        "--no-legend",
        "--width", "#{width}",
        "--height", "#{height}",
        "--imgformat", "PNG"
      ) rescue alt = "Gráfico no disponible"
    when "Contract"
      RRD::Wrapper.graph!(
        path_img(gname),
        "-s", time,
        "DEF:down_prio=#{path_rrd}:down_prio:AVERAGE",
        "DEF:down_dfl=#{path_rrd}:down_dfl:AVERAGE",
        "DEF:up_prio=#{path_rrd}:up_prio:AVERAGE",
        "DEF:up_dfl=#{path_rrd}:up_dfl:AVERAGE",
        "CDEF:down_prio_=down_prio,8,*",
        "CDEF:down_dfl_=down_dfl,8,*",
        "CDEF:up_prio_=up_prio,8,*",
        "CDEF:up_dfl_=up_dfl,8,*",
        "AREA:down_prio_#00AA00:down",
        "STACK:down_dfl_#00EE00:down p2p",
        "LINE1:up_prio_#FF0000:up",
        "STACK:up_dfl_#FF6600:up p2p",
        "HRULE:#{element.plan.ceil_down*1024}#00AA0066",
        "HRULE:#{element.plan.ceil_up*1024}#FF000066",
        "--upper-limit=#{element.plan.ceil_down*1000}",
        "--interlaced",
        "--lower-limit=0",
        "--x-grid", xgrid,
        "--alt-y-grid",
        "--no-legend",
        "--width", "#{width}",
        "--height", "#{height}",
        "--imgformat", "PNG"
      ) rescue alt = "Gráfico no disponible"
    end
    #"<a href=\"/graphs/#{element.id}/?class=#{element.class.to_s}\"><img src=\"/images/rrd/#{gname}.png\"></a>"
    "<img alt=\"#{alt}\" src=\"/images/rrd/#{gname}.png\">"
  end
end
