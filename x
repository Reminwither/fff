// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Mxwll Capital

//@version=5
indicator("Pivot Profit Target", overlay=true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_polylines_count = 100)

show         = input.bool(defval = true, title= "Show Previous Projections")
showPath     = input.bool(defval = true, title = "Show Price Path")
showPivotLab = input.bool(defval = true, title = "Show Pivot Label")

ph = (ta.pivothigh(high, 20, 20))
pl = (ta.pivotlow ( low, 20, 20))

type preValuesObjects
    
    line  pvLine
    line  pvStart
    label pvLabel
    box   pvBox

type preValues 
    
    int   phT 
    float phP 
    float phP1 
    float plP1 
    int   phTime 
    int   plTime

    float htl 
    float ltl 
    float btl 
    float ttl 



var pv = matrix.new<preValuesObjects>(4, 1), var phLen = matrix.new<float>(9), var plLen = matrix.new<float>(9), var int dir = 0

method divide(float id, float ) => 
    
    float / id - 1


method pivotCalcH(matrix <float> id, matrix<float> id2) =>

    var timeArr = array.new<int>(), var closeArr = array.new<float>()

    timeArr.unshift(time), closeArr.unshift(close)


    var preValues [] valArr = array.from(
                             
                             preValues.new(phT  = 0                  ), 
                             preValues.new(phP  = close              ), 
                             preValues.new(phP1 = close              ), 
                             preValues.new(plP1 = close              ), 
                             preValues.new(phTime = 0                ),
                             preValues.new(plTime = 0                )
     ) 


    var stats = map.new<string, int>()

    if stats.size() == 0 

        stats.put("Total", 0)
        stats.put("Success", 0)


    bv = preValues.new(htl = high[20], ltl = low[20], btl = bar_index[20], ttl = time[20])

    if not na(ph) and dir != 1

        if show and plLen.columns() > 0 and phLen.columns() > 0
    
            if not na(pv.get(0, 0))

                pv.get(1, 0).pvBox.set_right(int(valArr.get(5).plTime))
                pv.get(2, 0).pvLine.set_x2  (int(valArr.get(5).plTime))

                stats.put("Total" , stats.get("Total") + 1)

                points = array.new<chart.point>()

                for i =  timeArr.indexof(pv.get(1, 0).pvBox.get_left()) to timeArr.indexof(int(valArr.get(5).plTime))
                    
                    points.push(chart.point.from_time(timeArr.get(i), closeArr.get(i)))

                    if closeArr.get(i) >= pv.get(1, 0).pvBox.get_bottom()

                        stats.put("Success", stats.get("Success") + 1)

                        if showPath
                            polyline.new(points, xloc = xloc.bar_time, line_color = #14D990, line_width = 2)

                        break


            pv.set(0, 0, preValuesObjects.new(pvStart = 
                         
                         line.new(
                             
                             int(phLen.get(2, 0)), 
                             phLen.get(3, 0),
                             int(phLen.get(2, 0)),
                             phLen.get(3, 0) * (1 + plLen.row(4).median()), 
                             color = #F26948, 
                             style = line.style_dotted, 
                             xloc  = xloc.bar_time
             )))
                 
      
            pv.set(1, 0, preValuesObjects.new(pvBox = 
                             box.new(         int(phLen.get(2, 0)), 
                             phLen.get(3, 0) * (1 + plLen.row(5).median()),
                             time,
                             phLen.get(3, 0) * (1 + plLen.row(4).median()), 
                             bgcolor      = color.new(#F26948, 80), 
                             border_color = color.new(color.white, 80),
                             border_width = 1,                                     
                             xloc = xloc.bar_time


                      )))
                 

            pv.set(2, 0, preValuesObjects.new(pvLine = 
                             line.new(
                             int(phLen.get(2, 0)), 
                             phLen.get(3, 0) * (1 + plLen.row(1).median()),
                             time, 
                             phLen.get(3, 0) * (1 + plLen.row(1).median()), color = color.new(#F26948, 50), 
                             style = line.style_solid,                                      
                             xloc = xloc.bar_time
             )))

                
            pv.set(3, 0, preValuesObjects.new(pvLabel = 
                                         label.new(        int(phLen.get(2, 0)), phLen.get(3, 0) * 1.01, 
                                         style = label.style_text_outline, 
                                         text = showPivotLab ? "⬤" : "", 
                                         color =color.white, 
                                         textcolor = #F26948,
                                         size = size.small,                                     
                                         xloc = xloc.bar_time


                     )))
                 
        switchCond = bv.htl > valArr.get(2).phP1
        [r4, r5, r6, r7] = switch switchCond
            
            true => [na, valArr.get(1).phP.divide(bv.htl), na, bv.btl - valArr.get(1).phP]
            =>      [valArr.get(1).phP.divide(bv.htl), na, bv.btl - valArr.get(1).phP, na]

        r8 = switch bv.htl > valArr.get(1).phP
            
            true => valArr.get(1).phP.divide(bv.htl)
            =>      na

        id.add_col(0, array.from(bv.btl - valArr.get(1).phP, 
         valArr.get(1).phP.divide(bv.htl), bv.ttl, bv.htl, r4, r5, r6, r7, r8))
        
        valArr.set(0, preValues.new(phT = int(bv.btl))), valArr.set(2, preValues.new(phP1 = valArr.get(1).phP))
        valArr.set(1, preValues.new(phP = bv.htl))     , valArr.set(5, preValues.new(plTime = int(bv.ttl)))

        
    if not na(pl) and dir != -1

        if show and plLen.columns() > 0 and phLen.columns() > 0
            if not na(pv.get(0, 0))

                pv.get(1, 0).pvBox.set_right(int(valArr.get(4).phTime))
                pv.get(2, 0).pvLine.set_x2  (int(valArr.get(4).phTime))

                stats.put("Total" , stats.get("Total") + 1)

                points = array.new<chart.point>()

                for i =  timeArr.indexof(pv.get(1, 0).pvBox.get_left()) to timeArr.indexof(int(valArr.get(4).phTime))
                    
                    points.push(chart.point.from_time(timeArr.get(i), closeArr.get(i)))

                    if closeArr.get(i) <= pv.get(1, 0).pvBox.get_bottom()

                        stats.put("Success", stats.get("Success") + 1)

                        if showPath
                            polyline.new(points, xloc = xloc.bar_time, line_color = #F24968, line_width = 2)

                        break




            pv.set(0, 0, 
                     
                     preValuesObjects.new(pvStart = 
                         
                         line.new(
                             
                             int(plLen.get(2, 0)), 
                             plLen.get    (3, 0),
                             int(plLen.get(2, 0)),
                             plLen.get    (3, 0) * (1 + phLen.row(4).median()), 
                             color = #14D990, 
                             style = line.style_dotted,
                             xloc  = xloc.bar_time
             )))

             
                  
            pv.set(1, 0, 
                     
                     preValuesObjects.new(pvBox = 
                         
                         box.new(int(plLen.get(2, 0)), 
                             
                             plLen.get(3, 0) * (1 + phLen.row(5).median()),
                             time,
                             plLen.get(3, 0) * (1 + phLen.row(4).median()), 
                             bgcolor      = color.new(#14D990, 80), 
                             border_color = color.new(color.white, 80),
                             border_width = 1,                                     
                             xloc         = xloc.bar_time

                  )))
             
            pv.set(2, 0, 
                
                 preValuesObjects.new(pvLine = 
                         
                         line.new(

                             int(plLen.get(2, 0)), 
                             plLen.get(3, 0) * (1 + phLen.row(1).median()),
                             time,
                             plLen.get(3, 0) * (1 + phLen.row(1).median()), 
                             color = color.new(#14D990, 50), 
                             style = line.style_solid,
                             xloc  = xloc.bar_time
             )))

            
            pv.set(3, 0, 
                 
                 preValuesObjects.new(
                    
                     pvLabel = label.new(int(plLen.get(2, 0)), plLen.get(3, 0) * .99, 
                                     style     = label.style_text_outline, 
                                     text      = showPivotLab ? "⬤" : "", 
                                     color     =color.white, 
                                     textcolor = color.aqua,
                                     size      = size.small,
                                     xloc      = xloc.bar_time
                 )))
                 

        switchCond2 = bv.ltl < valArr.get(3).plP1
        [r4, r5, r6, r7] = switch switchCond2
            
            true => [na, valArr.get(1).phP.divide(bv.ltl), na, bv.btl - valArr.get(1).phP]
            =>      [valArr.get(1).phP.divide(bv.ltl), na, bv.btl - valArr.get(1).phP, na]

        r8 = switch bv.ltl < valArr.get(1).phP
            
            true => valArr.get(1).phP.divide(bv.ltl)
            =>      na


        id2.add_col(0, array.from(bv.btl - valArr.get(1).phP, 
         valArr.get(1).phP.divide(bv.ltl), bv.ttl, bv.ltl, r4, r5, r6, r7, r8))
        
        valArr.set(0, preValues.new(phT = int(bv.btl))), valArr.set(3, preValues.new(plP1 = valArr.get(1).phP))
        valArr.set(1, preValues.new(phP = bv.ltl))       , valArr.set(4, preValues.new(phTime = int(bv.ttl)))

    stats

stats = phLen.pivotCalcH(plLen)

if not na(ph)
    dir := 1
if not na(pl)
    dir := -1


if barstate.islast 

    var tab = table.new(position.bottom_right, 99, 99, bgcolor = #20222C, border_color = #363843, frame_color = #363843, border_width = 1, frame_width = 1)
    tab.cell(0, 0, "Projections", text_color = color.white)
    tab.cell(1, 0, "Successful", text_color = color.white)
    tab.cell(2, 0, "Failed", text_color = color.white)

    getTotal   = stats.get("Total")
    getSuccess = stats.get("Success")

    tab.cell(0, 1, str.tostring(getTotal), text_color = color.white)
    tab.cell(1, 1, str.tostring(getSuccess), text_color = #14D990)
    tab.cell(2, 1, str.tostring(getTotal - getSuccess), text_color = #F24968)


    var line [] projectLine = array.new_line(), var label [] projectLabel = array.new_label(), var box [] projectBox = array.new_box()
    
    if projectLine.size() > 0 
        for i = 0 to projectLine.size() - 1
            projectLine.shift().delete()
    
    if projectLabel.size() > 0 
        for i = 0 to projectLabel.size() - 1
            projectLabel.shift().delete()
    
    if projectBox.size() > 0 
        for i = 0 to projectBox.size() - 1
            projectBox.shift().delete()

    switch dir

        1  =>  projectLine.unshift(
                     line.new(
                             int(plLen.get(2, 0)), 
                             plLen.get(3, 0),
                             int(plLen.get(2, 0)),
                             plLen.get(3, 0) * (1 + phLen.row(4).median()), 
                             color = #14D990, 
                             style = line.style_dotted, 
                             xloc  = xloc.bar_time
                         )), 
                 
                 projectBox.unshift(
                      
                       box.new(int(plLen.get(2, 0)), 
                             plLen.get(3, 0) * (1 + phLen.row(5).median()),
                             time,
                             plLen.get(3, 0) * (1 + phLen.row(4).median()), 
                             bgcolor      = color.new(#14D990, 80), 
                             border_color = color.new(color.white, 80),
                             border_width = 1,                                     
                             xloc         = xloc.bar_time


                      )
                 ),

                 projectLine.unshift(
                     line.new(
                             int(plLen.get(2, 0)), 
                             plLen.get(3, 0) * (1 + phLen.row(1).median()),
                             time,
                             plLen.get(3, 0) * (1 + phLen.row(1).median()), color = color.new(#14D990, 50), 
                             style = line.style_solid,                                     
                             xloc  = xloc.bar_time
                             )), 
                
                 projectLabel.unshift(
                     label.new(int(plLen.get(2, 0)), plLen.get(3, 0) * .99, 
                                         style     = label.style_text_outline, 
                                         text      = showPivotLab ? "⬤" : "", 
                                         color     =color.white, 
                                         textcolor = color.aqua,
                                         size      = size.small,                                      
                                         xloc      = xloc.bar_time


                     )
                 )

        -1 => projectLine.unshift(
                     line.new(
                             int(phLen.get(2, 0)), 
                             phLen.get(3, 0),
                             int(phLen.get(2, 0)),
                             phLen.get(3, 0) * (1 + plLen.row(4).median()), 
                             color = #F26948, 
                             style = line.style_dotted,                                      
                             xloc  = xloc.bar_time
                     )), 
                 
                 projectBox.unshift(
                      
                       box.new(int(phLen.get(2, 0)), 
                             phLen.get(3, 0) * (1 + plLen.row(5).median()),
                             time,
                             phLen.get(3, 0) * (1 + plLen.row(4).median()), 
                             bgcolor      = color.new(#F26948, 80), 
                             border_color = color.new(color.white, 80),
                             border_width = 1,                                      
                             xloc = xloc.bar_time


                      )
                 ),

                 projectLine.unshift(
                     line.new(
                             int(phLen.get(2, 0)), 
                             phLen.get(3, 0) * (1 + plLen.row(1).median()),
                             time, 
                             phLen.get(3, 0) * (1 + plLen.row(1).median()), color = color.new(#F26948, 50), 
                             style = line.style_solid,                              
                             xloc  = xloc.bar_time
                                 )), 
                
                 projectLabel.unshift(
                     label.new(int(phLen.get(2, 0)), phLen.get(3, 0) * 1.01, 
                                         style     = label.style_text_outline, 
                                         text      = showPivotLab ? "⬤" : "", 
                                         color     =color.white, 
                                         textcolor = #F26948,
                                         size      = size.small,                             
                                         xloc      = xloc.bar_time


                     )
                 )


// 代码2
indicator(title='Twin Range Filter', overlay=true, timeframe='')
source = input(defval=close, title='Source')
showsignals = input(title='Show Buy/Sell Signals ?', defval=true)
per1 = input.int(defval=27, minval=1, title='Fast period')
mult1 = input.float(defval=1.6, minval=0.1, title='Fast range')
per2 = input.int(defval=55, minval=1, title='Slow period')
mult2 = input.float(defval=2, minval=0.1, title='Slow range')
smoothrng(x, t, m) =>
    wper = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    smoothrng = ta.ema(avrng, wper) * m
    smoothrng
smrng1 = smoothrng(source, per1, mult1)
smrng2 = smoothrng(source, per2, mult2)
smrng = (smrng1 + smrng2) / 2
rngfilt(x, r) =>
    rngfilt = x
    rngfilt := x > nz(rngfilt[1]) ? x - r < nz(rngfilt[1]) ? nz(rngfilt[1]) : x - r : x + r > nz(rngfilt[1]) ? nz(rngfilt[1]) : x + r
    rngfilt
filt = rngfilt(source, smrng)
upward = 0.0
upward := filt > filt[1] ? nz(upward[1]) + 1 : filt < filt[1] ? 0 : nz(upward[1])
downward = 0.0
downward := filt < filt[1] ? nz(downward[1]) + 1 : filt > filt[1] ? 0 : nz(downward[1])
STR = filt + smrng
STS = filt - smrng
FUB = 0.0
FUB := STR < nz(FUB[1]) or close[1] > nz(FUB[1]) ? STR : nz(FUB[1])
FLB = 0.0
FLB := STS > nz(FLB[1]) or close[1] < nz(FLB[1]) ? STS : nz(FLB[1])
TRF = 0.0
TRF := nz(TRF[1]) == FUB[1] and close <= FUB ? FUB : nz(TRF[1]) == FUB[1] and close >= FUB ? FLB : nz(TRF[1]) == FLB[1] and close >= FLB ? FLB : nz(TRF[1]) == FLB[1] and close <= FLB ? FUB : FUB
long = ta.crossover(close, TRF)
short = ta.crossunder(close, TRF)
plotshape(showsignals and long, title='Long', text='BUY', style=shape.labelup, textcolor=color.white, size=size.tiny, location=location.belowbar, color=color.rgb(0, 19, 230))
plotshape(showsignals and short, title='Short', text='SELL', style=shape.labeldown, textcolor=color.white, size=size.tiny, location=location.abovebar, color=color.rgb(0, 19, 230))
alertcondition(long, title='Long', message='Long')
alertcondition(short, title='Short', message='Short')
Trfff = plot(TRF)
mPlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0)
longFillColor = close > TRF ? color.green : na
shortFillColor = close < TRF ? color.red : na
fill(mPlot, Trfff, title='UpTrend Highligter', color=longFillColor, transp=90)
fill(mPlot, Trfff, title='DownTrend Highligter', color=shortFillColor, transp=90)
