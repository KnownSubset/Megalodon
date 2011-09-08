-module(stock_manager_tests).
-export ([test/0]).

test() ->
    eunit:test ({
        setup,
        fun () -> io:format ("~n** Make sure mongod is running on 127.0.0.1:27017 **~n~n", []) end,
        fun (_) -> io:format ("~n** Make sure mongod is running on 127.0.0.1:27017 **~n~n", []) end,
        [fun macd_test/0]}).

macd_test() ->
    Closings = [12156.81,11740.15,11893.69,12040.39,12254.99,12213.80,12258.90,12266.39,12582.18,12694.28,12684.92,12570.22,
                12381.02,12284.30,12427.26,12337.22,12348.21,12376.98,12552.24,12373.41,12240.01,12182.13,12247.00,12200.10,
                 12265.13,12635.16,12743.19,12650.36,12442.83,12480.30,12383.89,12207.17,12378.61,12270.17,11971.19,12099.30,
                 12159.21,12466.16,12501.11,12778.15,12606.30,12853.09,12735.31,12589.07,12827.49,12800.18,13056.72,13043.96],
    AllClosings = lists:reverse([13043.96,13056.72,12800.18,12827.49,12589.07,12735.31,12853.09,12606.30,12778.15,12501.11,12466.16,12159.21,12099.30,11971.19,12270.17,12378.61,12207.17,12383.89,12480.30,12442.83,12650.36,12743.19,
                                 12635.16,12265.13,12200.10,12247.00,12182.13,12240.01,12373.41,12552.24,12376.98,12348.21,12337.22,12427.26,12284.30,12381.02,12570.22,12684.92,12694.28,12582.18,12266.39,12258.90,12213.80,12254.99,12040.39,11893.69,11740.15,12156.81,12110.24,12145.74,11951.09,11972.25,12392.66,12099.66,12361.32,12548.64,
                                 12532.60,12422.86,12302.46,12216.40,12262.89,12654.36,12608.92,12626.03,12609.42,12612.43,12576.44,12527.26,12581.98,12325.42,12302.06,12362.47,12619.27,12620.49,12849.36,12825.02,12720.23,12763.22,12848.95,12891.86,12871.75,12831.94,12820.13,13010.00,13058.20,12969.54,13020.83,12814.35,12866.78,12745.88,
                                 12876.05,12832.18,12898.38,12992.66,12986.80,13028.16,12828.68,12601.19,12625.62,12479.63,12548.35,12594.03,12646.22,12638.32,12503.82,12402.85,12390.48,12604.45,12209.81,12280.32,12289.76,12083.77,12141.58,12307.35,12269.08,12160.30,12029.06,12063.09,11842.69,11842.36,11807.43,11811.83,11453.42,11346.51,
                                 11350.01,11382.26,11215.51,11288.53,11231.96,11384.21,11147.44,11229.02,11100.54,11055.19,10962.54,11239.28,11446.66,11496.57,11467.34,11602.50,11632.38,11349.28,11370.69,11131.08,11397.56,11583.69,11378.02,11326.32,11284.15,11615.77,11656.07,11431.43,11734.32,11782.35,11642.47,11532.96,11615.93,11659.90,
                                 11479.39,11348.55,11417.43,11430.21,11628.06,11386.25,11412.87,11502.51,11715.18,11543.55,11516.92,11532.88,11188.23,11220.96,11510.74,11230.73,11268.92,11433.71,11421.99,10917.51,11059.02,10609.66,11019.69,11388.44,11015.69,10854.17,10825.17,11022.06,11143.13,10365.45,10850.66,10831.07,10482.85,10325.38,
                                 9955.50,9447.11,9258.10,8579.19,8451.19,9387.61,9310.99,8577.91,8979.26,8852.22,9265.43,9045.21,8519.21,8691.25,8378.95,8175.77,9065.12,8990.96,9180.69,9325.01,9319.83,9625.28,9139.27,8695.79,8943.81,8870.54,8693.96,8282.66,8835.25,8497.31,8273.58,8424.75,7997.28,7552.29,8046.42,8443.39,8479.47,8726.61,
                                 8829.04,8149.09,8419.09,8591.69,8376.24,8635.42,8934.18,8691.33,8761.42,8565.09,8629.68,8564.53,8924.14,8824.34,8604.99,8579.11,8519.69,8419.49,8468.48,8515.55,8483.93,8668.39,8776.39,9034.69,8952.89,9015.10,8769.70,8742.46,8599.18,8473.97,8448.56,8200.14,8212.49,8281.22,7949.09,8228.10,8122.80,8077.56,
                                 8116.03,8174.73,8375.45,8149.01,8000.86,7936.83,8078.36,7956.66,8063.07,8280.59,8270.87,7888.88,7939.53,7932.76,7850.41,7552.60,7555.63,7465.95,7365.67,7114.78,7350.94,7270.89,7182.08,7062.93,6763.29,6726.02,6875.84,6594.44,6626.94,6547.05,6926.49,6930.40,7170.06,7223.98,7216.97,7395.70,7486.58,7400.80,
                                 7278.38,7775.86,7660.21,7749.81,7924.56,7776.18,7522.02,7608.92,7761.60,7978.08,8017.59,7975.85,7789.56,7837.11,8083.38,8057.81,7920.18,8029.62,8125.43,8131.33,7841.73,7969.56,7886.57,7957.06,8076.29,8025.00,8016.95,8185.73,8168.12,8212.41,8426.74,8410.65,8512.28,8409.85,8574.65]),
    Macd = -105.79616469174289,
    Macd = macd:calculate(Closings),
    Macds = [-105.79616469174289,-104.00553320214749,-80.38399662775919, -61.1085660538065,-46.485864580618,-40.651796492562426, -31.788010892685634,-23.912050463397463,-15.270771538302142, -21.48789955223947,-34.17028515513266,-47.958263420401636, -57.58768507619243,-58.67129188175568,-54.763415632498436, -57.40857634013264,-55.6170183926497,-53.941661672619375, -53.30939636963558,-61.320537566358325,-61.082484896578535, -53.79901246796908,-42.393330976354264],
    Macds = macd:calculateAll(Closings),
    Signals = macd:signalLine(AllClosings, 9),
    SignalHistory = [75.02110738655294,63.2251649537466,51.883664597391004,40.33419425542794,29.430928509100983,18.947073516131507,9.328750249807925,-0.34340723973290227,-10.164042302689504,-19.861404572718282,-30.281745359842546,-41.369526940219465,-52.76978366682205,-65.11322593199043,-78.8805954126257,-93.68528726614015,-110.36047488558611,-127.28168703008957,-144.25850953584035,-161.62661320916106,-179.9008856837424,-198.1556064973204,-215.93103521316, -234.38836806710626,-253.7392635922297,-272.75591459467205,-290.80668893747514,-307.6308402843244,-324.05502913376057,
                     -340.74420327834395,-358.13052328720033,-374.58852756412875,-388.7435726390442,-400.9519822866601,-411.1729432336572,-418.09442817535177,-424.01568470703177,-427.9501760154974,-428.9152158826179,-426.8432665382375,-422.26972957135047,-414.7462173253949,-404.14642198717326,-391.55061486916185,-376.8733971441722,-362.43235415922743,-348.25105617497024,-335.06291942952294,-321.7797435787565,-309.752665921162,-299.48392552020294,-289.90350193769666,-280.7754859065304,-271.97823561513826,-263.40132257206653,-256.9075396725573,-251.72857086221777,-247.81234709666296,-245.13168093386605,
                     -244.21479116787214,-243.78414496670848,-243.56989231111936,-243.70394810573077,-244.71286185930433,-244.497704693769,-242.77396743434787,-240.65534516480704,-238.86354783215108,-236.86048261218028,-235.63795432636874,-235.13688147991772,-234.7312327726218,-233.12157590898764,-231.39209672200715,-230.0245661965568,-229.49697331289937,-229.86890367656713,-230.8155710336152,-234.35645218612777,-239.12742800083777,-245.91476215735435,-255.32415613875776,-266.4187119480141,-279.3915693742399,-293.82077728601934,-309.02888945997097,-324.88030113284896,-339.80739478625657,-353.792950297872,
                     -365.9246050343104,-377.24640300277684,-388.1565491039649,-399.6634276529401,-411.6718024418183,-424.5558445051517,-438.7928973031493,-454.0210149245711,-470.0239314680449,-486.7301230767866,-502.8100154547771,-517.3477654355485,-532.1367951503784,-546.764613465892,-561.5403696730749,-575.2018736911443,-587.8630197736815,-597.7044136821289,-605.9138876765079,-613.7935284732645,-619.9953776486115,-625.306259297897,-631.3713086245687,-634.2321678956486,-633.8836121509668,-631.3068017754428,-626.4563646161213,-621.6162967590913,-620.3176818197961,-621.0166094996043,
                     -621.812530638808,-623.9602416835652,-626.6483034503312,-628.1041571669062,-631.7588084658759,-635.8133090648805,-639.4587019893443,-642.3301023126046,-646.023845573712,-648.1614663916546,-645.4700413406694,-638.9084411959284,-627.8017366805457,-612.3298217431743,-593.0955190984932,-569.2588749804618,-545.9646261566309,-522.8049346319674,-498.55151021677153,-474.7306162909847,-448.8283757066242,-419.6137851337696,-389.6025337353665,-358.57061710965496,-329.6018417674027,-299.3568601667251,-267.7638598570203,-241.19162561056783,-220.87840295800618,-204.75874903299945,
                     -193.218942297337,-184.6185905434095,-177.68001349854367,-172.08622642668124,-166.18811693478509,-159.97578189657406,-156.65269134000056,-152.20914322041833,-147.26802579165067,-143.11501963893897,-139.9352724706946,-137.09999569817518,-132.45394419766953,-128.0006276412707,-126.5538896813663,-126.17285014636792,-128.1178659958658,-129.8390139619931,-131.22287337858214,-133.2556051102216,-136.37762929918682,-139.10481609577838,-143.17830781312816,-149.15836403334282,-155.32142429989784,-161.7613645728901,-168.32411537774195,-173.89071597887397,-179.5018699055884,-185.7045940720813,
                     -192.7864948366249,-199.39130784980216,-206.59876063725545,-214.59993543315437,-223.98276354475212,-234.20208946584737,-244.23316945338118,-254.2050625811811,-264.5364471983309,-274.5340158413462,-283.13111657658544,-290.19529485624287,-297.2145898807722,-302.7354007409168,-306.62222731359884,-310.5919085798148,-314.4571637322927,-317.922249293563,-319.6398221736348,-320.4207749904721,-321.8313586290616,-322.63758220343925,-322.9384640675781,-320.93329973897454,-316.3627322965685,-309.6172543501121,-300.1915675602529,-287.9961020102204,-273.9709858959813,-259.7894277557686,
                     -245.23321138522513,-230.32603085725472,-214.56968168432513,-198.6756125971197,-181.5216822696063,-164.16975744870663,-146.6425643377075,-129.78947126709207,-113.1470166809828,-97.37804972766192,-83.12022086636404,-70.44671751001455,-57.81161137630071,-45.54398064926287,-33.800307165878735,-22.984206967758965,-12.186084315595767,-1.8587801522331313,8.48597260739369,19.332790368827073,30.845952538631657,41.92800361363302,51.87926091588711,61.51356935956752,70.50977916055486,78.08679038864825,86.2407991991101,93.6383469210305,100.03698028617264,105.71485380206737,
                     111.25801777950058,116.61418543457813,121.34057345334915,124.92877306568481,126.60868110785128,126.80436650553253,125.00372719980386,122.19718487956955,119.49038913518952,116.75861674461602,114.14244695595198,111.18044915064986,107.46824556238181,103.2041473250474,97.54334567483293,91.0319063147171,83.27862487618226,75.4542329898507,67.41058570458684,59.85011532869755,52.784914277418935,45.315313419841644,37.58148633352895,29.942536648132002,22.72599149180239,15.936745874701792,9.29653623506333,2.7160444155940064,-2.9825536279002876,-7.2828468171618095,
                     -11.168235156163016,-14.4556542006323,-18.551862608333035,-23.98759229231026,-30.88163096292985,-37.87423667291597,-45.21187448315457,-52.544062599175426,-59.51084192787775,-65.91176267386025,-71.3808645598803,-75.68760045454877,-78.16592455175577,-80.78541350751276,-83.86287511979293,-86.95099439592383,-89.26148832104815,-89.87336714714485,-88.24318040191358,-85.01753531413362,-81.52670394611523,-75.94290070171756,-70.51431237598848,-65.56404808070556,-60.11892473231165,-54.40926973738274,-48.20973680428715,-44.18795432635314,-42.07287786042147,-41.5212545203969,
                     -41.62993677387621,-42.86017750902503,-45.22869338972848,-48.97343362115677,-52.40912537977144,-54.68898040785129,-55.53032003128249,-55.27314940066875,-54.84838159053288],
    Signals = SignalHistory.
