create table transaction_outputs
(
    output_id int8 NOT NULL,
    value          int8 NOT NULL,
    coinbase       bool NOT NULL,
    spend          bool NOT NULL,
    scriptbytes    bytea NOT NULL,
    CONSTRAINT transaction_outputs_pk PRIMARY KEY (output_id, spend)
) partition by list(spend)
;

-- Main partitions by spend
CREATE TABLE transaction_outputs_open PARTITION OF transaction_outputs
    FOR VALUES in (false) partition by range(output_id);

CREATE TABLE transaction_outputs_spend PARTITION OF transaction_outputs
    FOR VALUES in (true) partition by range(output_id);

-- Second level by spend and coin type
-- -- open
CREATE TABLE transaction_outputs_open_btc PARTITION OF transaction_outputs_open
    FOR VALUES FROM (288230376151711744) TO (576460752303423487) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_test PARTITION OF transaction_outputs_open
    FOR VALUES FROM (576460752303423488) TO (864691128455135231) partition by range(output_id);





CREATE TABLE transaction_outputs_open_btc_test_default PARTITION OF transaction_outputs_open_btc_test DEFAULT;
CREATE TABLE transaction_outputs_open_btc_sig PARTITION OF transaction_outputs_open
    FOR VALUES FROM (864691128455135232) TO (1152921504606846975) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_sig_default PARTITION OF transaction_outputs_open_btc_sig DEFAULT;
CREATE TABLE transaction_outputs_open_btc_reg PARTITION OF transaction_outputs_open
    FOR VALUES FROM (1152921504606846976) TO (1441151880758558719) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_reg_default PARTITION OF transaction_outputs_open_btc_reg DEFAULT;
-- -- spend
CREATE TABLE transaction_outputs_spend_btc PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (288230376151711744) TO (576460752303423487) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_test PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (576460752303423488) TO (864691128455135231) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_test_0k_200k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (576460752303423488) TO (577319745762623487);
CREATE TABLE transaction_outputs_spend_btc_test_200k_400k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (577319745762623488) TO (578178739221823487);
CREATE TABLE transaction_outputs_spend_btc_test_400k_600k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (578178739221823488) TO (579037732681023487);
CREATE TABLE transaction_outputs_spend_btc_test_600k_800k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (579037732681023488) TO (579896726140223487);
CREATE TABLE transaction_outputs_spend_btc_test_800k_1000k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (579896726140223488) TO (580755719599423487);
CREATE TABLE transaction_outputs_spend_btc_test_1000k_1200k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (580755719599423488) TO (581614713058623487);
CREATE TABLE transaction_outputs_spend_btc_test_1200k_1400k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (581614713058623488) TO (582473706517823487) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_test_1200k_1400k_1 PARTITION OF transaction_outputs_spend_btc_test_1200k_1400k
    FOR VALUES FROM (581614713058623488) TO (581829461423423487);
CREATE TABLE transaction_outputs_spend_btc_test_1200k_1400k_2 PARTITION OF transaction_outputs_spend_btc_test_1200k_1400k
    FOR VALUES FROM (581829461423423488) TO (582473706517823487);
CREATE TABLE transaction_outputs_spend_btc_test_1400k_1600k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (582473706517823488) TO (583332699977023487) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_test_1400k_1600k_1 PARTITION OF transaction_outputs_spend_btc_test_1400k_1600k
    FOR VALUES FROM (582473706517823488) TO (582903203247423487);
CREATE TABLE transaction_outputs_spend_btc_test_1400k_1600k_2 PARTITION OF transaction_outputs_spend_btc_test_1400k_1600k
    FOR VALUES FROM (582903203247423488) TO (583332699977023487);
CREATE TABLE transaction_outputs_spend_btc_test_1600k_1800k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (583332699977023488) TO (584191693436223487);
CREATE TABLE transaction_outputs_spend_btc_test_1800k_2000k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (584191693436223488) TO (585050686895423487);
CREATE TABLE transaction_outputs_spend_btc_test_2000k_2200k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (585050686895423488) TO (585909680354623487);
CREATE TABLE transaction_outputs_spend_btc_test_2200k_2400k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (585909680354623488) TO (586768673813823487);
CREATE TABLE transaction_outputs_spend_btc_test_2400k_2600k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (586768673813823488) TO (587627667273023487);
CREATE TABLE transaction_outputs_spend_btc_test_2600k_2800k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (587627667273023488) TO (588486660732223487);
CREATE TABLE transaction_outputs_spend_btc_test_2800k_3000k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (588486660732223488) TO (589345654191423487);
CREATE TABLE transaction_outputs_spend_btc_test_3000k_3200k PARTITION OF transaction_outputs_spend_btc_test
    FOR VALUES FROM (589345654191423488) TO (590204647650623487);


CREATE TABLE transaction_outputs_spend_btc_test_default PARTITION OF transaction_outputs_spend_btc_test DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_sig PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (864691128455135232) TO (1152921504606846975) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_sig_default PARTITION OF transaction_outputs_spend_btc_sig DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_reg PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (1152921504606846976) TO (1441151880758558719) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_reg_default PARTITION OF transaction_outputs_spend_btc_reg DEFAULT;

-- Third level by spend and coin type and range transactions (for btc)
-- -- -- open
CREATE TABLE transaction_outputs_open_btc_0_200k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (288230376151711744) TO (289089369610911743);
CREATE TABLE transaction_outputs_open_btc_200k_250k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289089369610911744) TO (289304117975711743);
CREATE TABLE transaction_outputs_open_btc_250k_300k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289304117975711744) TO (289518866340511743);
CREATE TABLE transaction_outputs_open_btc_300k_330k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289518866340511744) TO (289647715359391743);
CREATE TABLE transaction_outputs_open_btc_330k_360k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289647715359391744) TO (289776564378271743);
CREATE TABLE transaction_outputs_open_btc_360k_370k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289776564378271744) TO (289819514051231743);
CREATE TABLE transaction_outputs_open_btc_370k_380k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289819514051231744) TO (289862463724191743);
CREATE TABLE transaction_outputs_open_btc_380k_390k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289862463724191744) TO (289905413397151743);
CREATE TABLE transaction_outputs_open_btc_390k_400k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289905413397151744) TO (289948363070111743);
CREATE TABLE transaction_outputs_open_btc_400k_410k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289948363070111744) TO (289991312743071743);
CREATE TABLE transaction_outputs_open_btc_410k_420k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (289991312743071744) TO (290034262416031743);
CREATE TABLE transaction_outputs_open_btc_420k_430k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290034262416031744) TO (290077212088991743);
CREATE TABLE transaction_outputs_open_btc_430k_440k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290077212088991744) TO (290120161761951743);
CREATE TABLE transaction_outputs_open_btc_440k_450k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290120161761951744) TO (290163111434911743);
CREATE TABLE transaction_outputs_open_btc_450k_460k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290163111434911744) TO (290206061107871743);
CREATE TABLE transaction_outputs_open_btc_460k_470k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290206061107871744) TO (290249010780831743);
CREATE TABLE transaction_outputs_open_btc_470k_480k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290249010780831744) TO (290291960453791743);
CREATE TABLE transaction_outputs_open_btc_480k_490k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290291960453791744) TO (290334910126751743);
CREATE TABLE transaction_outputs_open_btc_490k_500k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290334910126751744) TO (290377859799711743);
CREATE TABLE transaction_outputs_open_btc_500k_510k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290377859799711744) TO (290420809472671743);
CREATE TABLE transaction_outputs_open_btc_510k_520k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290420809472671744) TO (290463759145631743);
CREATE TABLE transaction_outputs_open_btc_520k_530k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290463759145631744) TO (290506708818591743);
CREATE TABLE transaction_outputs_open_btc_530k_540k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290506708818591744) TO (290549658491551743);
CREATE TABLE transaction_outputs_open_btc_540k_550k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290549658491551744) TO (290592608164511743);
CREATE TABLE transaction_outputs_open_btc_550k_560k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290592608164511744) TO (290635557837471743);
CREATE TABLE transaction_outputs_open_btc_560k_570k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290635557837471744) TO (290678507510431743);
CREATE TABLE transaction_outputs_open_btc_570k_580k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290678507510431744) TO (290721457183391743);
CREATE TABLE transaction_outputs_open_btc_580k_590k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290721457183391744) TO (290764406856351743);
CREATE TABLE transaction_outputs_open_btc_590k_600k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290764406856351744) TO (290807356529311743);
CREATE TABLE transaction_outputs_open_btc_600k_610k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290807356529311744) TO (290850306202271743);
CREATE TABLE transaction_outputs_open_btc_610k_620k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290850306202271744) TO (290893255875231743);
CREATE TABLE transaction_outputs_open_btc_620k_630k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290893255875231744) TO (290936205548191743);
CREATE TABLE transaction_outputs_open_btc_630k_640k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290936205548191744) TO (290979155221151743);
CREATE TABLE transaction_outputs_open_btc_640k_650k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (290979155221151744) TO (291022104894111743);
CREATE TABLE transaction_outputs_open_btc_650k_660k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291022104894111744) TO (291065054567071743);
CREATE TABLE transaction_outputs_open_btc_660k_670k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291065054567071744) TO (291108004240031743);
CREATE TABLE transaction_outputs_open_btc_670k_680k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291108004240031744) TO (291150953912991743);
CREATE TABLE transaction_outputs_open_btc_680k_690k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291150953912991744) TO (291193903585951743);
CREATE TABLE transaction_outputs_open_btc_690k_700k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291193903585951744) TO (291236853258911743);
CREATE TABLE transaction_outputs_open_btc_700k_710k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291236853258911744) TO (291279802931871743);
CREATE TABLE transaction_outputs_open_btc_710k_720k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291279802931871744) TO (291322752604831743);
CREATE TABLE transaction_outputs_open_btc_720k_730k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291322752604831744) TO (291365702277791743);
CREATE TABLE transaction_outputs_open_btc_730k_740k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291365702277791744) TO (291408651950751743);
CREATE TABLE transaction_outputs_open_btc_740k_750k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291408651950751744) TO (291451601623711743);
CREATE TABLE transaction_outputs_open_btc_750k_760k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291451601623711744) TO (291494551296671743);
CREATE TABLE transaction_outputs_open_btc_760k_770k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291494551296671744) TO (291537500969631743);
CREATE TABLE transaction_outputs_open_btc_770k_780k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291537500969631744) TO (291580450642591743);
CREATE TABLE transaction_outputs_open_btc_780k_790k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291580450642591744) TO (291623400315551743);
CREATE TABLE transaction_outputs_open_btc_790k_800k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291623400315551744) TO (291666349988511743);
CREATE TABLE transaction_outputs_open_btc_800k_810k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291666349988511744) TO (291709299661471743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_800k_810k_default PARTITION OF transaction_outputs_open_btc_800k_810k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_810k_820k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291709299661471744) TO (291752249334431743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_810k_820k_default PARTITION OF transaction_outputs_open_btc_810k_820k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_820k_830k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291752249334431744) TO (291795199007391743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_820k_830k_default PARTITION OF transaction_outputs_open_btc_820k_830k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_830k_840k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291795199007391744) TO (291838148680351743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_830k_840k_default PARTITION OF transaction_outputs_open_btc_830k_840k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_840k_850k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291838148680351744) TO (291881098353311743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_840k_850k_default PARTITION OF transaction_outputs_open_btc_840k_850k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_850k_860k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291881098353311744) TO (291924048026271743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_850k_860k_default PARTITION OF transaction_outputs_open_btc_850k_860k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_860k_870k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291924048026271744) TO (291966997699231743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_860k_870k_default PARTITION OF transaction_outputs_open_btc_860k_870k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_870k_880k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (291966997699231744) TO (292009947372191743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_870k_880k_default PARTITION OF transaction_outputs_open_btc_870k_880k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_880k_890k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292009947372191744) TO (292052897045151743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_880k_890k_default PARTITION OF transaction_outputs_open_btc_880k_890k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_890k_900k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292052897045151744) TO (292095846718111743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_890k_900k_default PARTITION OF transaction_outputs_open_btc_890k_900k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_900k_910k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292095846718111744) TO (292138796391071743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_900k_910k_default PARTITION OF transaction_outputs_open_btc_900k_910k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_910k_920k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292138796391071744) TO (292181746064031743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_910k_920k_default PARTITION OF transaction_outputs_open_btc_910k_920k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_920k_930k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292181746064031744) TO (292224695736991743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_920k_930k_default PARTITION OF transaction_outputs_open_btc_920k_930k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_930k_940k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292224695736991744) TO (292267645409951743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_930k_940k_default PARTITION OF transaction_outputs_open_btc_930k_940k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_940k_950k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292267645409951744) TO (292310595082911743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_940k_950k_default PARTITION OF transaction_outputs_open_btc_940k_950k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_950k_960k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292310595082911744) TO (292353544755871743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_950k_960k_default PARTITION OF transaction_outputs_open_btc_950k_960k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_960k_970k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292353544755871744) TO (292396494428831743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_960k_970k_default PARTITION OF transaction_outputs_open_btc_960k_970k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_970k_980k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292396494428831744) TO (292439444101791743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_970k_980k_default PARTITION OF transaction_outputs_open_btc_970k_980k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_980k_990k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292439444101791744) TO (292482393774751743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_980k_990k_default PARTITION OF transaction_outputs_open_btc_980k_990k DEFAULT;
CREATE TABLE transaction_outputs_open_btc_990k_1000k PARTITION OF transaction_outputs_open_btc
    FOR VALUES FROM (292482393774751744) TO (292525343447711743) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_990k_1000k_default PARTITION OF transaction_outputs_open_btc_990k_1000k DEFAULT;



-- -- -- close
CREATE TABLE transaction_outputs_spend_btc_0_150k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (288230376151711744) TO (288874621246111743);
CREATE TABLE transaction_outputs_spend_btc_150k_160k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (288874621246111744) TO (288917570919071743);
CREATE TABLE transaction_outputs_spend_btc_160k_170k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (288917570919071744) TO (288960520592031743);
CREATE TABLE transaction_outputs_spend_btc_170k_180k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (288960520592031744) TO (289003470264991743);
CREATE TABLE transaction_outputs_spend_btc_180k_190k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289003470264991744) TO (289046419937951743);
CREATE TABLE transaction_outputs_spend_btc_190k_200k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289046419937951744) TO (289089369610911743);
CREATE TABLE transaction_outputs_spend_btc_200k_210k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289089369610911744) TO (289132319283871743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_200k_210k_1 PARTITION OF transaction_outputs_spend_btc_200k_210k
    FOR VALUES FROM (289089369610911744) TO (289110844447391743);
CREATE TABLE transaction_outputs_spend_btc_200k_210k_2 PARTITION OF transaction_outputs_spend_btc_200k_210k
    FOR VALUES FROM (289110844447391744) TO (289132319283871743);
CREATE TABLE transaction_outputs_spend_btc_210k_220k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289132319283871744) TO (289175268956831743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_210k_220k_1 PARTITION OF transaction_outputs_spend_btc_210k_220k
    FOR VALUES FROM (289132319283871744) TO (289153794120351743);
CREATE TABLE transaction_outputs_spend_btc_210k_220k_2 PARTITION OF transaction_outputs_spend_btc_210k_220k
    FOR VALUES FROM (289153794120351744) TO (289175268956831743);
CREATE TABLE transaction_outputs_spend_btc_220k_230k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289175268956831744) TO (289218218629791743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_220k_230k_1 PARTITION OF transaction_outputs_spend_btc_220k_230k
    FOR VALUES FROM (289175268956831744) TO (289196743793311743);
CREATE TABLE transaction_outputs_spend_btc_220k_230k_2 PARTITION OF transaction_outputs_spend_btc_220k_230k
    FOR VALUES FROM (289196743793311744) TO (289218218629791743);
CREATE TABLE transaction_outputs_spend_btc_230k_240k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289218218629791744) TO (289261168302751743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_230k_240k_1 PARTITION OF transaction_outputs_spend_btc_230k_240k
    FOR VALUES FROM (289218218629791744) TO (289239693466271743);
CREATE TABLE transaction_outputs_spend_btc_230k_240k_2 PARTITION OF transaction_outputs_spend_btc_230k_240k
    FOR VALUES FROM (289239693466271744) TO (289261168302751743);
CREATE TABLE transaction_outputs_spend_btc_240k_250k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289261168302751744) TO (289304117975711743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_240k_250k_1 PARTITION OF transaction_outputs_spend_btc_240k_250k
    FOR VALUES FROM (289261168302751744) TO (289282643139231743);
CREATE TABLE transaction_outputs_spend_btc_240k_250k_2 PARTITION OF transaction_outputs_spend_btc_240k_250k
    FOR VALUES FROM (289282643139231744) TO (289304117975711743);
CREATE TABLE transaction_outputs_spend_btc_250k_260k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289304117975711744) TO (289347067648671743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_250k_260k_1 PARTITION OF transaction_outputs_spend_btc_250k_260k
    FOR VALUES FROM (289304117975711744) TO (289325592812191743);
CREATE TABLE transaction_outputs_spend_btc_250k_260k_2 PARTITION OF transaction_outputs_spend_btc_250k_260k
    FOR VALUES FROM (289325592812191744) TO (289347067648671743);
CREATE TABLE transaction_outputs_spend_btc_260k_270k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289347067648671744) TO (289390017321631743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_260k_270k_1 PARTITION OF transaction_outputs_spend_btc_260k_270k
    FOR VALUES FROM (289347067648671744) TO (289368542485151743);
CREATE TABLE transaction_outputs_spend_btc_260k_270k_2 PARTITION OF transaction_outputs_spend_btc_260k_270k
    FOR VALUES FROM (289368542485151744) TO (289390017321631743);
CREATE TABLE transaction_outputs_spend_btc_270k_280k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289390017321631744) TO (289432966994591743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_270k_280k_1 PARTITION OF transaction_outputs_spend_btc_270k_280k
    FOR VALUES FROM (289390017321631744) TO (289411492158111743);
CREATE TABLE transaction_outputs_spend_btc_270k_280k_2 PARTITION OF transaction_outputs_spend_btc_270k_280k
    FOR VALUES FROM (289411492158111744) TO (289432966994591743);
CREATE TABLE transaction_outputs_spend_btc_280k_290k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289432966994591744) TO (289475916667551743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_280k_290k_1 PARTITION OF transaction_outputs_spend_btc_280k_290k
    FOR VALUES FROM (289432966994591744) TO (289454441831071743);
CREATE TABLE transaction_outputs_spend_btc_280k_290k_2 PARTITION OF transaction_outputs_spend_btc_280k_290k
    FOR VALUES FROM (289454441831071744) TO (289475916667551743);
CREATE TABLE transaction_outputs_spend_btc_290k_300k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289475916667551744) TO (289518866340511743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_290k_300k_1 PARTITION OF transaction_outputs_spend_btc_290k_300k
    FOR VALUES FROM (289475916667551744) TO (289497391504031743);
CREATE TABLE transaction_outputs_spend_btc_290k_300k_2 PARTITION OF transaction_outputs_spend_btc_290k_300k
    FOR VALUES FROM (289497391504031744) TO (289518866340511743);
CREATE TABLE transaction_outputs_spend_btc_300k_310k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289518866340511744) TO (289561816013471743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_300k_310k_1 PARTITION OF transaction_outputs_spend_btc_300k_310k
    FOR VALUES FROM (289518866340511744) TO (289533181466509311);
CREATE TABLE transaction_outputs_spend_btc_300k_310k_2 PARTITION OF transaction_outputs_spend_btc_300k_310k
    FOR VALUES FROM (289533181466509312) TO (289547496592506879);
CREATE TABLE transaction_outputs_spend_btc_300k_310k_3 PARTITION OF transaction_outputs_spend_btc_300k_310k
    FOR VALUES FROM (289547496592506880) TO (289561816013471743);
CREATE TABLE transaction_outputs_spend_btc_310k_320k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289561816013471744) TO (289604765686431743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_310k_320k_1 PARTITION OF transaction_outputs_spend_btc_310k_320k
		FOR VALUES FROM (289561816013471744) TO (289576131139469311);
CREATE TABLE transaction_outputs_spend_btc_310k_320k_2 PARTITION OF transaction_outputs_spend_btc_310k_320k
		FOR VALUES FROM (289576131139469312) TO (289590446265466879);
CREATE TABLE transaction_outputs_spend_btc_310k_320k_3 PARTITION OF transaction_outputs_spend_btc_310k_320k
		FOR VALUES FROM (289590446265466880) TO (289604765686431743);
CREATE TABLE transaction_outputs_spend_btc_320k_330k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289604765686431744) TO (289647715359391743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_320k_330k_1 PARTITION OF transaction_outputs_spend_btc_320k_330k
		FOR VALUES FROM (289604765686431744) TO (289615503104671743);
CREATE TABLE transaction_outputs_spend_btc_320k_330k_2 PARTITION OF transaction_outputs_spend_btc_320k_330k
		FOR VALUES FROM (289615503104671744) TO (289626240522911743);
CREATE TABLE transaction_outputs_spend_btc_320k_330k_3 PARTITION OF transaction_outputs_spend_btc_320k_330k
		FOR VALUES FROM (289626240522911744) TO (289636977941151743);
CREATE TABLE transaction_outputs_spend_btc_320k_330k_4 PARTITION OF transaction_outputs_spend_btc_320k_330k
		FOR VALUES FROM (289636977941151744) TO (289647715359391743);
CREATE TABLE transaction_outputs_spend_btc_330k_340k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289647715359391744) TO (289690665032351743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_330k_340k_1 PARTITION OF transaction_outputs_spend_btc_330k_340k
		FOR VALUES FROM (289647715359391744) TO (289658452777631743);
CREATE TABLE transaction_outputs_spend_btc_330k_340k_2 PARTITION OF transaction_outputs_spend_btc_330k_340k
		FOR VALUES FROM (289658452777631744) TO (289669190195871743);
CREATE TABLE transaction_outputs_spend_btc_330k_340k_3 PARTITION OF transaction_outputs_spend_btc_330k_340k
		FOR VALUES FROM (289669190195871744) TO (289679927614111743);
CREATE TABLE transaction_outputs_spend_btc_330k_340k_4 PARTITION OF transaction_outputs_spend_btc_330k_340k
		FOR VALUES FROM (289679927614111744) TO (289690665032351743);
CREATE TABLE transaction_outputs_spend_btc_340k_350k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289690665032351744) TO (289733614705311743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_340k_350k_1 PARTITION OF transaction_outputs_spend_btc_340k_350k
    FOR VALUES FROM (289690665032351744) TO (289699254966943743);
CREATE TABLE transaction_outputs_spend_btc_340k_350k_2 PARTITION OF transaction_outputs_spend_btc_340k_350k
    FOR VALUES FROM (289699254966943744) TO (289707844901535743);
CREATE TABLE transaction_outputs_spend_btc_340k_350k_3 PARTITION OF transaction_outputs_spend_btc_340k_350k
    FOR VALUES FROM (289707844901535744) TO (289716434836127743);
CREATE TABLE transaction_outputs_spend_btc_340k_350k_4 PARTITION OF transaction_outputs_spend_btc_340k_350k
    FOR VALUES FROM (289716434836127744) TO (289725024770719743);
CREATE TABLE transaction_outputs_spend_btc_340k_350k_5 PARTITION OF transaction_outputs_spend_btc_340k_350k
    FOR VALUES FROM (289725024770719744) TO (289733614705311743);
CREATE TABLE transaction_outputs_spend_btc_350k_360k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289733614705311744) TO (289776564378271743) PARTITION BY RANGE (output_id);
CREATE TABLE transaction_outputs_spend_btc_350k_360k_1 PARTITION OF transaction_outputs_spend_btc_350k_360k
    FOR VALUES FROM (289733614705311744) TO (289742204639903743);
CREATE TABLE transaction_outputs_spend_btc_350k_360k_2 PARTITION OF transaction_outputs_spend_btc_350k_360k
    FOR VALUES FROM (289742204639903744) TO (289750794574495743);
CREATE TABLE transaction_outputs_spend_btc_350k_360k_3 PARTITION OF transaction_outputs_spend_btc_350k_360k
    FOR VALUES FROM (289750794574495744) TO (289759384509087743);
CREATE TABLE transaction_outputs_spend_btc_350k_360k_4 PARTITION OF transaction_outputs_spend_btc_350k_360k
    FOR VALUES FROM (289759384509087744) TO (289767974443679743);
CREATE TABLE transaction_outputs_spend_btc_350k_360k_5 PARTITION OF transaction_outputs_spend_btc_350k_360k
    FOR VALUES FROM (289767974443679744) TO (289776564378271743);
CREATE TABLE transaction_outputs_spend_btc_360k_370k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289776564378271744) TO (289819514051231743) PARTITION BY RANGE (output_id);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_1 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289776564378271744) TO (289783719793786879);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_2 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289783719793786880) TO (289790875209302015);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_3 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289790875209302016) TO (289798030624817151);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_4 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289798030624817152) TO (289805186040332287);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_5 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289805186040332288) TO (289812341455847423);
CREATE TABLE transaction_outputs_spend_btc_360k_370k_6 PARTITION OF transaction_outputs_spend_btc_360k_370k
    FOR VALUES FROM (289812341455847424) TO (289819514051231743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289819514051231744) TO (289862463724191743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_1 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289819514051231744) TO (289824882760351743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_2 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289824882760351744) TO (289830251469471743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_3 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289830251469471744) TO (289835620178591743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_4 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289835620178591744) TO (289840988887711743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_5 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289840988887711744) TO (289846357596831743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_6 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289846357596831744) TO (289851726305951743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_7 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289851726305951744) TO (289857095015071743);
CREATE TABLE transaction_outputs_spend_btc_370k_380k_8 PARTITION OF transaction_outputs_spend_btc_370k_380k
    FOR VALUES FROM (289857095015071744) TO (289862463724191743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289862463724191744) TO (289905413397151743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_1 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289862463724191744) TO (289867832433311743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_2 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289867832433311744) TO (289873201142431743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_3 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289873201142431744) TO (289878569851551743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_4 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289878569851551744) TO (289883938560671743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_5 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289883938560671744) TO (289889307269791743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_6 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289889307269791744) TO (289894675978911743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_7 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289894675978911744) TO (289900044688031743);
CREATE TABLE transaction_outputs_spend_btc_380k_390k_8 PARTITION OF transaction_outputs_spend_btc_380k_390k
		FOR VALUES FROM (289900044688031744) TO (289905413397151743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289905413397151744) TO (289948363070111743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_1 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289905413397151744) TO (289910782106271743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_2 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289910782106271744) TO (289916150815391743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_3 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289916150815391744) TO (289921519524511743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_4 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289921519524511744) TO (289926888233631743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_5 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289926888233631744) TO (289932256942751743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_6 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289932256942751744) TO (289937625651871743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_7 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289937625651871744) TO (289942994360991743);
CREATE TABLE transaction_outputs_spend_btc_390k_400k_8 PARTITION OF transaction_outputs_spend_btc_390k_400k
    FOR VALUES FROM (289942994360991744) TO (289948363070111743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289948363070111744) TO (289991312743071743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_1 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289948363070111744) TO (289953731779231743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_2 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289953731779231744) TO (289959100488351743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_3 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289959100488351744) TO (289964469197471743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_4 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289964469197471744) TO (289969837906591743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_5 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289969837906591744) TO (289975206615711743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_6 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289975206615711744) TO (289980575324831743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_7 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289980575324831744) TO (289985944033951743);
CREATE TABLE transaction_outputs_spend_btc_400k_410k_8 PARTITION OF transaction_outputs_spend_btc_400k_410k
    FOR VALUES FROM (289985944033951744) TO (289991312743071743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (289991312743071744) TO (290034262416031743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_1 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (289991312743071744) TO (289995607710367743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_2 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (289995607710367744) TO (289999902677663743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_3 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (289999902677663744) TO (290004197644959743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_4 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290004197644959744) TO (290008492612255743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_5 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290008492612255744) TO (290012787579551743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_6 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290012787579551744) TO (290017082546847743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_7 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290017082546847744) TO (290021377514143743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_8 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290021377514143744) TO (290025672481439743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_9 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290025672481439744) TO (290029967448735743);
CREATE TABLE transaction_outputs_spend_btc_410k_420k_10 PARTITION OF transaction_outputs_spend_btc_410k_420k
    FOR VALUES FROM (290029967448735744) TO (290034262416031743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290034262416031744) TO (290077212088991743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_1 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290034262416031744) TO (290038557383327743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_2 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290038557383327744) TO (290042852350623743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_3 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290042852350623744) TO (290047147317919743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_4 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290047147317919744) TO (290051442285215743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_5 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290051442285215744) TO (290055737252511743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_6 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290055737252511744) TO (290060032219807743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_7 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290060032219807744) TO (290064327187103743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_8 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290064327187103744) TO (290068622154399743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_9 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290068622154399744) TO (290072917121695743);
CREATE TABLE transaction_outputs_spend_btc_420k_430k_10 PARTITION OF transaction_outputs_spend_btc_420k_430k
    FOR VALUES FROM (290072917121695744) TO (290077212088991743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290077212088991744) TO (290120161761951743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_1 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290077212088991744) TO (290081507056287743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_2 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290081507056287744) TO (290085802023583743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_3 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290085802023583744) TO (290090096990879743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_4 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290090096990879744) TO (290094391958175743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_5 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290094391958175744) TO (290098686925471743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_6 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290098686925471744) TO (290102981892767743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_7 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290102981892767744) TO (290107276860063743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_8 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290107276860063744) TO (290111571827359743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_9 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290111571827359744) TO (290115866794655743);
CREATE TABLE transaction_outputs_spend_btc_430k_440k_10 PARTITION OF transaction_outputs_spend_btc_430k_440k
    FOR VALUES FROM (290115866794655744) TO (290120161761951743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290120161761951744) TO (290163111434911743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_1 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290120161761951744) TO (290124456729247743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_2 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290124456729247744) TO (290128751696543743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_3 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290128751696543744) TO (290133046663839743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_4 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290133046663839744) TO (290137341631135743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_5 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290137341631135744) TO (290141636598431743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_6 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290141636598431744) TO (290145931565727743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_7 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290145931565727744) TO (290150226533023743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_8 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290150226533023744) TO (290154521500319743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_9 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290154521500319744) TO (290158816467615743);
CREATE TABLE transaction_outputs_spend_btc_440k_450k_10 PARTITION OF transaction_outputs_spend_btc_440k_450k
    FOR VALUES FROM (290158816467615744) TO (290163111434911743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290163111434911744) TO (290206061107871743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_1 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290163111434911744) TO (290167406402207743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_2 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290167406402207744) TO (290171701369503743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_3 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290171701369503744) TO (290175996336799743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_4 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290175996336799744) TO (290180291304095743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_5 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290180291304095744) TO (290184586271391743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_6 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290184586271391744) TO (290188881238687743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_7 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290188881238687744) TO (290193176205983743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_8 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290193176205983744) TO (290197471173279743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_9 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290197471173279744) TO (290201766140575743);
CREATE TABLE transaction_outputs_spend_btc_450k_460k_10 PARTITION OF transaction_outputs_spend_btc_450k_460k
    FOR VALUES FROM (290201766140575744) TO (290206061107871743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290206061107871744) TO (290249010780831743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_1 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290206061107871744) TO (290210356075167743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_2 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290210356075167744) TO (290214651042463743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_3 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290214651042463744) TO (290218946009759743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_4 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290218946009759744) TO (290223240977055743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_5 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290223240977055744) TO (290227535944351743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_6 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290227535944351744) TO (290231830911647743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_7 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290231830911647744) TO (290236125878943743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_8 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290236125878943744) TO (290240420846239743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_9 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290240420846239744) TO (290244715813535743);
CREATE TABLE transaction_outputs_spend_btc_460k_470k_10 PARTITION OF transaction_outputs_spend_btc_460k_470k
    FOR VALUES FROM (290244715813535744) TO (290249010780831743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290249010780831744) TO (290291960453791743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_1 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290249010780831744) TO (290253305748127743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_2 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290253305748127744) TO (290257600715423743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_3 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290257600715423744) TO (290261895682719743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_4 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290261895682719744) TO (290266190650015743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_5 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290266190650015744) TO (290270485617311743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_6 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290270485617311744) TO (290274780584607743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_7 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290274780584607744) TO (290279075551903743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_8 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290279075551903744) TO (290283370519199743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_9 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290283370519199744) TO (290287665486495743);
CREATE TABLE transaction_outputs_spend_btc_470k_480k_10 PARTITION OF transaction_outputs_spend_btc_470k_480k
    FOR VALUES FROM (290287665486495744) TO (290291960453791743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290291960453791744) TO (290334910126751743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_1 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290291960453791744) TO (290296255421087743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_2 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290296255421087744) TO (290300550388383743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_3 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290300550388383744) TO (290304845355679743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_4 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290304845355679744) TO (290309140322975743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_5 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290309140322975744) TO (290313435290271743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_6 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290313435290271744) TO (290317730257567743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_7 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290317730257567744) TO (290322025224863743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_8 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290322025224863744) TO (290326320192159743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_9 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290326320192159744) TO (290330615159455743);
CREATE TABLE transaction_outputs_spend_btc_480k_490k_10 PARTITION OF transaction_outputs_spend_btc_480k_490k
    FOR VALUES FROM (290330615159455744) TO (290334910126751743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290334910126751744) TO (290377859799711743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_1 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290334910126751744) TO (290339205094047743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_2 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290339205094047744) TO (290343500061343743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_3 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290343500061343744) TO (290347795028639743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_4 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290347795028639744) TO (290352089995935743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_5 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290352089995935744) TO (290356384963231743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_6 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290356384963231744) TO (290360679930527743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_7 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290360679930527744) TO (290364974897823743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_8 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290364974897823744) TO (290369269865119743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_9 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290369269865119744) TO (290373564832415743);
CREATE TABLE transaction_outputs_spend_btc_490k_500k_10 PARTITION OF transaction_outputs_spend_btc_490k_500k
    FOR VALUES FROM (290373564832415744) TO (290377859799711743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290377859799711744) TO (290420809472671743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_1 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290377859799711744) TO (290382154767007743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_2 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290382154767007744) TO (290386449734303743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_3 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290386449734303744) TO (290390744701599743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_4 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290390744701599744) TO (290395039668895743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_5 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290395039668895744) TO (290399334636191743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_6 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290399334636191744) TO (290403629603487743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_7 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290403629603487744) TO (290407924570783743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_8 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290407924570783744) TO (290412219538079743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_9 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290412219538079744) TO (290416514505375743);
CREATE TABLE transaction_outputs_spend_btc_500k_510k_10 PARTITION OF transaction_outputs_spend_btc_500k_510k
    FOR VALUES FROM (290416514505375744) TO (290420809472671743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290420809472671744) TO (290463759145631743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_1 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290420809472671744) TO (290425104439967743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_2 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290425104439967744) TO (290429399407263743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_3 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290429399407263744) TO (290433694374559743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_4 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290433694374559744) TO (290437989341855743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_5 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290437989341855744) TO (290442284309151743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_6 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290442284309151744) TO (290446579276447743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_7 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290446579276447744) TO (290450874243743743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_8 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290450874243743744) TO (290455169211039743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_9 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290455169211039744) TO (290459464178335743);
CREATE TABLE transaction_outputs_spend_btc_510k_520k_10 PARTITION OF transaction_outputs_spend_btc_510k_520k
    FOR VALUES FROM (290459464178335744) TO (290463759145631743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290463759145631744) TO (290506708818591743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_1 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290463759145631744) TO (290468054112927743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_2 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290468054112927744) TO (290472349080223743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_3 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290472349080223744) TO (290476644047519743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_4 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290476644047519744) TO (290480939014815743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_5 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290480939014815744) TO (290485233982111743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_6 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290485233982111744) TO (290489528949407743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_7 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290489528949407744) TO (290493823916703743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_8 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290493823916703744) TO (290498118883999743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_9 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290498118883999744) TO (290502413851295743);
CREATE TABLE transaction_outputs_spend_btc_520k_530k_10 PARTITION OF transaction_outputs_spend_btc_520k_530k
    FOR VALUES FROM (290502413851295744) TO (290506708818591743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290506708818591744) TO (290549658491551743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_1 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290506708818591744) TO (290511003785887743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_2 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290511003785887744) TO (290515298753183743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_3 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290515298753183744) TO (290519593720479743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_4 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290519593720479744) TO (290523888687775743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_5 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290523888687775744) TO (290528183655071743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_6 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290528183655071744) TO (290532478622367743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_7 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290532478622367744) TO (290536773589663743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_8 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290536773589663744) TO (290541068556959743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_9 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290541068556959744) TO (290545363524255743);
CREATE TABLE transaction_outputs_spend_btc_530k_540k_10 PARTITION OF transaction_outputs_spend_btc_530k_540k
    FOR VALUES FROM (290545363524255744) TO (290549658491551743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290549658491551744) TO (290592608164511743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_1 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290549658491551744) TO (290553953458847743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_2 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290553953458847744) TO (290558248426143743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_3 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290558248426143744) TO (290562543393439743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_4 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290562543393439744) TO (290566838360735743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_5 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290566838360735744) TO (290571133328031743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_6 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290571133328031744) TO (290575428295327743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_7 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290575428295327744) TO (290579723262623743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_8 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290579723262623744) TO (290584018229919743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_9 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290584018229919744) TO (290588313197215743);
CREATE TABLE transaction_outputs_spend_btc_540k_550k_10 PARTITION OF transaction_outputs_spend_btc_540k_550k
    FOR VALUES FROM (290588313197215744) TO (290592608164511743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290592608164511744) TO (290635557837471743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_1 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290592608164511744) TO (290596903131807743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_2 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290596903131807744) TO (290601198099103743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_3 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290601198099103744) TO (290605493066399743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_4 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290605493066399744) TO (290609788033695743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_5 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290609788033695744) TO (290614083000991743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_6 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290614083000991744) TO (290618377968287743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_7 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290618377968287744) TO (290622672935583743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_8 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290622672935583744) TO (290626967902879743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_9 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290626967902879744) TO (290631262870175743);
CREATE TABLE transaction_outputs_spend_btc_550k_560k_10 PARTITION OF transaction_outputs_spend_btc_550k_560k
    FOR VALUES FROM (290631262870175744) TO (290635557837471743);

CREATE TABLE transaction_outputs_spend_btc_560k_570k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290635557837471744) TO (290678507510431743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_1 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290635557837471744) TO (290639852804767743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_2 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290639852804767744) TO (290644147772063743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_3 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290644147772063744) TO (290648442739359743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_4 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290648442739359744) TO (290652737706655743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_5 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290652737706655744) TO (290657032673951743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_6 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290657032673951744) TO (290661327641247743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_7 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290661327641247744) TO (290665622608543743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_8 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290665622608543744) TO (290669917575839743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_9 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290669917575839744) TO (290674212543135743);
CREATE TABLE transaction_outputs_spend_btc_560k_570k_10 PARTITION OF transaction_outputs_spend_btc_560k_570k
    FOR VALUES FROM (290674212543135744) TO (290678507510431743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290678507510431744) TO (290721457183391743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_1 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290678507510431744) TO (290682802477727743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_2 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290682802477727744) TO (290687097445023743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_3 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290687097445023744) TO (290691392412319743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_4 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290691392412319744) TO (290695687379615743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_5 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290695687379615744) TO (290699982346911743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_6 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290699982346911744) TO (290704277314207743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_7 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290704277314207744) TO (290708572281503743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_8 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290708572281503744) TO (290712867248799743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_9 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290712867248799744) TO (290717162216095743);
CREATE TABLE transaction_outputs_spend_btc_570k_580k_10 PARTITION OF transaction_outputs_spend_btc_570k_580k
    FOR VALUES FROM (290717162216095744) TO (290721457183391743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290721457183391744) TO (290764406856351743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_1 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290721457183391744) TO (290725752150687743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_2 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290725752150687744) TO (290730047117983743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_3 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290730047117983744) TO (290734342085279743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_4 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290734342085279744) TO (290738637052575743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_5 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290738637052575744) TO (290742932019871743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_6 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290742932019871744) TO (290747226987167743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_7 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290747226987167744) TO (290751521954463743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_8 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290751521954463744) TO (290755816921759743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_9 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290755816921759744) TO (290760111889055743);
CREATE TABLE transaction_outputs_spend_btc_580k_590k_10 PARTITION OF transaction_outputs_spend_btc_580k_590k
    FOR VALUES FROM (290760111889055744) TO (290764406856351743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290764406856351744) TO (290807356529311743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_1 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290764406856351744) TO (290768701823647743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_2 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290768701823647744) TO (290772996790943743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_3 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290772996790943744) TO (290777291758239743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_4 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290777291758239744) TO (290781586725535743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_5 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290781586725535744) TO (290785881692831743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_6 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290785881692831744) TO (290790176660127743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_7 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290790176660127744) TO (290794471627423743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_8 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290794471627423744) TO (290798766594719743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_9 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290798766594719744) TO (290803061562015743);
CREATE TABLE transaction_outputs_spend_btc_590k_600k_10 PARTITION OF transaction_outputs_spend_btc_590k_600k
    FOR VALUES FROM (290803061562015744) TO (290807356529311743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290807356529311744) TO (290850306202271743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_1 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290807356529311744) TO (290811651496607743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_2 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290811651496607744) TO (290815946463903743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_3 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290815946463903744) TO (290820241431199743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_4 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290820241431199744) TO (290824536398495743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_5 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290824536398495744) TO (290828831365791743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_6 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290828831365791744) TO (290833126333087743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_7 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290833126333087744) TO (290837421300383743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_8 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290837421300383744) TO (290841716267679743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_9 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290841716267679744) TO (290846011234975743);
CREATE TABLE transaction_outputs_spend_btc_600k_610k_10 PARTITION OF transaction_outputs_spend_btc_600k_610k
    FOR VALUES FROM (290846011234975744) TO (290850306202271743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290850306202271744) TO (290893255875231743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_1 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290850306202271744) TO (290854601169567743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_2 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290854601169567744) TO (290858896136863743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_3 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290858896136863744) TO (290863191104159743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_4 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290863191104159744) TO (290867486071455743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_5 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290867486071455744) TO (290871781038751743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_6 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290871781038751744) TO (290876076006047743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_7 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290876076006047744) TO (290880370973343743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_8 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290880370973343744) TO (290884665940639743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_9 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290884665940639744) TO (290888960907935743);
CREATE TABLE transaction_outputs_spend_btc_610k_620k_10 PARTITION OF transaction_outputs_spend_btc_610k_620k
    FOR VALUES FROM (290888960907935744) TO (290893255875231743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290893255875231744) TO (290936205548191743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_1 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290893255875231744) TO (290897550842527743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_2 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290897550842527744) TO (290901845809823743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_3 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290901845809823744) TO (290906140777119743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_4 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290906140777119744) TO (290910435744415743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_5 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290910435744415744) TO (290914730711711743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_6 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290914730711711744) TO (290919025679007743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_7 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290919025679007744) TO (290923320646303743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_8 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290923320646303744) TO (290927615613599743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_9 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290927615613599744) TO (290931910580895743);
CREATE TABLE transaction_outputs_spend_btc_620k_630k_10 PARTITION OF transaction_outputs_spend_btc_620k_630k
    FOR VALUES FROM (290931910580895744) TO (290936205548191743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290936205548191744) TO (290979155221151743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_1 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290936205548191744) TO (290940500515487743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_2 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290940500515487744) TO (290944795482783743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_3 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290944795482783744) TO (290949090450079743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_4 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290949090450079744) TO (290953385417375743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_5 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290953385417375744) TO (290957680384671743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_6 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290957680384671744) TO (290961975351967743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_7 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290961975351967744) TO (290966270319263743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_8 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290966270319263744) TO (290970565286559743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_9 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290970565286559744) TO (290974860253855743);
CREATE TABLE transaction_outputs_spend_btc_630k_640k_10 PARTITION OF transaction_outputs_spend_btc_630k_640k
    FOR VALUES FROM (290974860253855744) TO (290979155221151743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (290979155221151744) TO (291022104894111743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_1 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (290979155221151744) TO (290983450188447743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_2 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (290983450188447744) TO (290987745155743743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_3 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (290987745155743744) TO (290992040123039743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_4 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (290992040123039744) TO (290996335090335743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_5 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (290996335090335744) TO (291000630057631743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_6 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (291000630057631744) TO (291004925024927743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_7 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (291004925024927744) TO (291009219992223743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_8 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (291009219992223744) TO (291013514959519743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_9 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (291013514959519744) TO (291017809926815743);
CREATE TABLE transaction_outputs_spend_btc_640k_650k_10 PARTITION OF transaction_outputs_spend_btc_640k_650k
    FOR VALUES FROM (291017809926815744) TO (291022104894111743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291022104894111744) TO (291065054567071743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_1 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291022104894111744) TO (291026399861407743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_2 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291026399861407744) TO (291030694828703743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_3 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291030694828703744) TO (291034989795999743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_4 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291034989795999744) TO (291039284763295743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_5 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291039284763295744) TO (291043579730591743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_6 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291043579730591744) TO (291047874697887743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_7 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291047874697887744) TO (291052169665183743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_8 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291052169665183744) TO (291056464632479743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_9 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291056464632479744) TO (291060759599775743);
CREATE TABLE transaction_outputs_spend_btc_650k_660k_10 PARTITION OF transaction_outputs_spend_btc_650k_660k
    FOR VALUES FROM (291060759599775744) TO (291065054567071743);
CREATE TABLE transaction_outputs_spend_btc_660k_670k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291065054567071744) TO (291108004240031743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_1 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291065054567071744) TO (291068632274829311);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_2 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291068632274829312) TO (291072209982586879);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_3 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291072209982586880) TO (291075787690344447);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_4 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291075787690344448) TO (291079365398102015);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_5 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291079365398102016) TO (291082943105859583);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_6 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291082943105859584) TO (291086520813617151);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_7 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291086520813617152) TO (291090098521374719);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_8 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291090098521374720) TO (291093676229132287);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_9 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291093676229132288) TO (291097253936889855);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_10 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291097253936889856) TO (291100831644647423);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_11 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291100831644647424) TO (291104409352404991);
CREATE TABLE transaction_outputs_spend_btc_660k_670k_12 PARTITION OF transaction_outputs_spend_btc_660k_670k
    FOR VALUES FROM (291104409352404992) TO (291108004240031743);
CREATE TABLE transaction_outputs_spend_btc_670k_680k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291108004240031744) TO (291150953912991743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_1 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291108004240031744) TO (291111581947789311);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_2 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291111581947789312) TO (291115159655546879);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_3 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291115159655546880) TO (291118737363304447);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_4 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291118737363304448) TO (291122315071062015);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_5 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291122315071062016) TO (291125892778819583);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_6 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291125892778819584) TO (291129470486577151);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_7 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291129470486577152) TO (291133048194334719);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_8 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291133048194334720) TO (291136625902092287);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_9 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291136625902092288) TO (291140203609849855);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_10 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291140203609849856) TO (291143781317607423);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_11 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291143781317607424) TO (291147359025364991);
CREATE TABLE transaction_outputs_spend_btc_670k_680k_12 PARTITION OF transaction_outputs_spend_btc_670k_680k
    FOR VALUES FROM (291147359025364992) TO (291150953912991743);
CREATE TABLE transaction_outputs_spend_btc_680k_690k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291150953912991744) TO (291193903585951743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_1 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291150953912991744) TO (291154531620749311);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_2 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291154531620749312) TO (291158109328506879);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_3 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291158109328506880) TO (291161687036264447);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_4 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291161687036264448) TO (291165264744022015);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_5 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291165264744022016) TO (291168842451779583);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_6 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291168842451779584) TO (291172420159537151);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_7 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291172420159537152) TO (291175997867294719);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_8 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291175997867294720) TO (291179575575052287);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_9 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291179575575052288) TO (291183153282809855);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_10 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291183153282809856) TO (291186730990567423);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_11 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291186730990567424) TO (291190308698324991);
CREATE TABLE transaction_outputs_spend_btc_680k_690k_12 PARTITION OF transaction_outputs_spend_btc_680k_690k
    FOR VALUES FROM (291190308698324992) TO (291193903585951743);
CREATE TABLE transaction_outputs_spend_btc_690k_700k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291193903585951744) TO (291236853258911743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_1 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291193903585951744) TO (291197481293709311);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_2 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291197481293709312) TO (291201059001466879);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_3 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291201059001466880) TO (291204636709224447);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_4 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291204636709224448) TO (291208214416982015);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_5 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291208214416982016) TO (291211792124739583);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_6 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291211792124739584) TO (291215369832497151);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_7 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291215369832497152) TO (291218947540254719);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_8 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291218947540254720) TO (291222525248012287);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_9 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291222525248012288) TO (291226102955769855);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_10 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291226102955769856) TO (291229680663527423);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_11 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291229680663527424) TO (291233258371284991);
CREATE TABLE transaction_outputs_spend_btc_690k_700k_12 PARTITION OF transaction_outputs_spend_btc_690k_700k
    FOR VALUES FROM (291233258371284992) TO (291236853258911743);
CREATE TABLE transaction_outputs_spend_btc_700k_710k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291236853258911744) TO (291279802931871743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_1 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291236853258911744) TO (291240430966669311);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_2 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291240430966669312) TO (291244008674426879);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_3 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291244008674426880) TO (291247586382184447);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_4 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291247586382184448) TO (291251164089942015);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_5 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291251164089942016) TO (291254741797699583);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_6 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291254741797699584) TO (291258319505457151);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_7 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291258319505457152) TO (291261897213214719);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_8 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291261897213214720) TO (291265474920972287);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_9 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291265474920972288) TO (291269052628729855);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_10 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291269052628729856) TO (291272630336487423);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_11 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291272630336487424) TO (291276208044244991);
CREATE TABLE transaction_outputs_spend_btc_700k_710k_12 PARTITION OF transaction_outputs_spend_btc_700k_710k
    FOR VALUES FROM (291276208044244992) TO (291279802931871743);
CREATE TABLE transaction_outputs_spend_btc_710k_720k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291279802931871744) TO (291322752604831743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_1 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291279802931871744) TO (291283380639629311);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_2 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291283380639629312) TO (291286958347386879);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_3 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291286958347386880) TO (291290536055144447);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_4 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291290536055144448) TO (291294113762902015);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_5 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291294113762902016) TO (291297691470659583);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_6 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291297691470659584) TO (291301269178417151);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_7 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291301269178417152) TO (291304846886174719);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_8 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291304846886174720) TO (291308424593932287);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_9 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291308424593932288) TO (291312002301689855);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_10 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291312002301689856) TO (291315580009447423);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_11 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291315580009447424) TO (291319157717204991);
CREATE TABLE transaction_outputs_spend_btc_710k_720k_12 PARTITION OF transaction_outputs_spend_btc_710k_720k
    FOR VALUES FROM (291319157717204992) TO (291322752604831743);
CREATE TABLE transaction_outputs_spend_btc_720k_730k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291322752604831744) TO (291365702277791743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_1 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291322752604831744) TO (291326330312589311);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_2 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291326330312589312) TO (291329908020346879);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_3 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291329908020346880) TO (291333485728104447);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_4 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291333485728104448) TO (291337063435862015);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_5 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291337063435862016) TO (291340641143619583);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_6 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291340641143619584) TO (291344218851377151);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_7 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291344218851377152) TO (291347796559134719);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_8 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291347796559134720) TO (291351374266892287);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_9 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291351374266892288) TO (291354951974649855);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_10 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291354951974649856) TO (291358529682407423);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_11 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291358529682407424) TO (291362107390164991);
CREATE TABLE transaction_outputs_spend_btc_720k_730k_12 PARTITION OF transaction_outputs_spend_btc_720k_730k
    FOR VALUES FROM (291362107390164992) TO (291365702277791743);
CREATE TABLE transaction_outputs_spend_btc_730k_740k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291365702277791744) TO (291408651950751743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_1 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291365702277791744) TO (291369279985549311);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_2 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291369279985549312) TO (291372857693306879);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_3 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291372857693306880) TO (291376435401064447);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_4 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291376435401064448) TO (291380013108822015);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_5 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291380013108822016) TO (291383590816579583);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_6 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291383590816579584) TO (291387168524337151);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_7 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291387168524337152) TO (291390746232094719);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_8 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291390746232094720) TO (291394323939852287);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_9 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291394323939852288) TO (291397901647609855);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_10 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291397901647609856) TO (291401479355367423);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_11 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291401479355367424) TO (291405057063124991);
CREATE TABLE transaction_outputs_spend_btc_730k_740k_12 PARTITION OF transaction_outputs_spend_btc_730k_740k
    FOR VALUES FROM (291405057063124992) TO (291408651950751743);
CREATE TABLE transaction_outputs_spend_btc_740k_750k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291408651950751744) TO (291451601623711743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_1 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291408651950751744) TO (291412229658509311);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_2 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291412229658509312) TO (291415807366266879);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_3 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291415807366266880) TO (291419385074024447);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_4 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291419385074024448) TO (291422962781782015);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_5 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291422962781782016) TO (291426540489539583);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_6 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291426540489539584) TO (291430118197297151);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_7 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291430118197297152) TO (291433695905054719);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_8 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291433695905054720) TO (291437273612812287);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_9 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291437273612812288) TO (291440851320569855);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_10 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291440851320569856) TO (291444429028327423);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_11 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291444429028327424) TO (291448006736084991);
CREATE TABLE transaction_outputs_spend_btc_740k_750k_12 PARTITION OF transaction_outputs_spend_btc_740k_750k
    FOR VALUES FROM (291448006736084992) TO (291451601623711743);
CREATE TABLE transaction_outputs_spend_btc_750k_760k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291451601623711744) TO (291494551296671743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_1 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291451601623711744) TO (291455179331469311);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_2 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291455179331469312) TO (291458757039226879);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_3 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291458757039226880) TO (291462334746984447);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_4 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291462334746984448) TO (291465912454742015);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_5 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291465912454742016) TO (291469490162499583);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_6 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291469490162499584) TO (291473067870257151);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_7 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291473067870257152) TO (291476645578014719);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_8 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291476645578014720) TO (291480223285772287);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_9 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291480223285772288) TO (291483800993529855);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_10 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291483800993529856) TO (291487378701287423);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_11 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291487378701287424) TO (291490956409044991);
CREATE TABLE transaction_outputs_spend_btc_750k_760k_12 PARTITION OF transaction_outputs_spend_btc_750k_760k
    FOR VALUES FROM (291490956409044992) TO (291494551296671743);
CREATE TABLE transaction_outputs_spend_btc_760k_770k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291494551296671744) TO (291537500969631743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_1 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291494551296671744) TO (291498129004429311);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_2 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291498129004429312) TO (291501706712186879);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_3 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291501706712186880) TO (291505284419944447);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_4 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291505284419944448) TO (291508862127702015);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_5 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291508862127702016) TO (291512439835459583);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_6 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291512439835459584) TO (291516017543217151);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_7 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291516017543217152) TO (291519595250974719);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_8 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291519595250974720) TO (291523172958732287);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_9 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291523172958732288) TO (291526750666489855);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_10 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291526750666489856) TO (291530328374247423);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_11 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291530328374247424) TO (291533906082004991);
CREATE TABLE transaction_outputs_spend_btc_760k_770k_12 PARTITION OF transaction_outputs_spend_btc_760k_770k
    FOR VALUES FROM (291533906082004992) TO (291537500969631743);
CREATE TABLE transaction_outputs_spend_btc_770k_780k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291537500969631744) TO (291580450642591743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_1 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291537500969631744) TO (291541078677389311);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_2 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291541078677389312) TO (291544656385146879);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_3 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291544656385146880) TO (291548234092904447);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_4 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291548234092904448) TO (291551811800662015);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_5 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291551811800662016) TO (291555389508419583);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_6 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291555389508419584) TO (291558967216177151);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_7 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291558967216177152) TO (291562544923934719);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_8 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291562544923934720) TO (291566122631692287);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_9 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291566122631692288) TO (291569700339449855);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_10 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291569700339449856) TO (291573278047207423);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_11 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291573278047207424) TO (291576855754964991);
CREATE TABLE transaction_outputs_spend_btc_770k_780k_12 PARTITION OF transaction_outputs_spend_btc_770k_780k
    FOR VALUES FROM (291576855754964992) TO (291580450642591743);
CREATE TABLE transaction_outputs_spend_btc_780k_790k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291580450642591744) TO (291623400315551743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_1 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291580450642591744) TO (291584028350349311);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_2 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291584028350349312) TO (291587606058106879);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_3 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291587606058106880) TO (291591183765864447);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_4 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291591183765864448) TO (291594761473622015);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_5 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291594761473622016) TO (291598339181379583);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_6 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291598339181379584) TO (291601916889137151);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_7 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291601916889137152) TO (291605494596894719);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_8 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291605494596894720) TO (291609072304652287);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_9 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291609072304652288) TO (291612650012409855);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_10 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291612650012409856) TO (291616227720167423);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_11 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291616227720167424) TO (291619805427924991);
CREATE TABLE transaction_outputs_spend_btc_780k_790k_12 PARTITION OF transaction_outputs_spend_btc_780k_790k
    FOR VALUES FROM (291619805427924992) TO (291623400315551743);
CREATE TABLE transaction_outputs_spend_btc_790k_800k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291623400315551744) TO (291666349988511743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_1 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291623400315551744) TO (291626978023309311);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_2 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291626978023309312) TO (291630555731066879);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_3 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291630555731066880) TO (291634133438824447);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_4 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291634133438824448) TO (291637711146582015);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_5 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291637711146582016) TO (291641288854339583);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_6 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291641288854339584) TO (291644866562097151);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_7 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291644866562097152) TO (291648444269854719);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_8 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291648444269854720) TO (291652021977612287);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_9 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291652021977612288) TO (291655599685369855);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_10 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291655599685369856) TO (291659177393127423);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_11 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291659177393127424) TO (291662755100884991);
CREATE TABLE transaction_outputs_spend_btc_790k_800k_12 PARTITION OF transaction_outputs_spend_btc_790k_800k
    FOR VALUES FROM (291662755100884992) TO (291666349988511743);
CREATE TABLE transaction_outputs_spend_btc_800k_810k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291666349988511744) TO (291709299661471743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_1 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291666349988511744) TO (291669927696269311);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_2 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291669927696269312) TO (291673505404026879);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_3 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291673505404026880) TO (291677083111784447);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_4 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291677083111784448) TO (291680660819542015);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_5 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291680660819542016) TO (291684238527299583);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_6 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291684238527299584) TO (291687816235057151);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_7 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291687816235057152) TO (291691393942814719);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_8 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291691393942814720) TO (291694971650572287);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_9 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291694971650572288) TO (291698549358329855);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_10 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291698549358329856) TO (291702127066087423);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_11 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291702127066087424) TO (291705704773844991);
CREATE TABLE transaction_outputs_spend_btc_800k_810k_12 PARTITION OF transaction_outputs_spend_btc_800k_810k
    FOR VALUES FROM (291705704773844992) TO (291709299661471743);

CREATE TABLE transaction_outputs_spend_btc_810k_820k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291709299661471744) TO (291752249334431743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_1 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291709299661471744) TO (291712877369229311);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_2 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291712877369229312) TO (291716455076986879);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_3 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291716455076986880) TO (291720032784744447);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_4 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291720032784744448) TO (291723610492502015);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_5 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291723610492502016) TO (291727188200259583);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_6 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291727188200259584) TO (291730765908017151);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_7 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291730765908017152) TO (291734343615774719);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_8 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291734343615774720) TO (291737921323532287);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_9 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291737921323532288) TO (291741499031289855);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_10 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291741499031289856) TO (291745076739047423);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_11 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291745076739047424) TO (291748654446804991);
CREATE TABLE transaction_outputs_spend_btc_810k_820k_12 PARTITION OF transaction_outputs_spend_btc_810k_820k
    FOR VALUES FROM (291748654446804992) TO (291752249334431743);
CREATE TABLE transaction_outputs_spend_btc_820k_830k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291752249334431744) TO (291795199007391743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_1 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291752249334431744) TO (291755827042189311);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_2 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291755827042189312) TO (291759404749946879);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_3 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291759404749946880) TO (291762982457704447);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_4 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291762982457704448) TO (291766560165462015);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_5 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291766560165462016) TO (291770137873219583);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_6 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291770137873219584) TO (291773715580977151);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_7 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291773715580977152) TO (291777293288734719);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_8 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291777293288734720) TO (291780870996492287);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_9 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291780870996492288) TO (291784448704249855);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_10 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291784448704249856) TO (291788026412007423);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_11 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291788026412007424) TO (291791604119764991);
CREATE TABLE transaction_outputs_spend_btc_820k_830k_12 PARTITION OF transaction_outputs_spend_btc_820k_830k
    FOR VALUES FROM (291791604119764992) TO (291795199007391743);
CREATE TABLE transaction_outputs_spend_btc_830k_840k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291795199007391744) TO (291838148680351743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_1 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291795199007391744) TO (291798776715149311);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_2 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291798776715149312) TO (291802354422906879);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_3 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291802354422906880) TO (291805932130664447);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_4 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291805932130664448) TO (291809509838422015);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_5 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291809509838422016) TO (291813087546179583);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_6 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291813087546179584) TO (291816665253937151);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_7 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291816665253937152) TO (291820242961694719);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_8 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291820242961694720) TO (291823820669452287);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_9 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291823820669452288) TO (291827398377209855);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_10 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291827398377209856) TO (291830976084967423);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_11 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291830976084967424) TO (291834553792724991);
CREATE TABLE transaction_outputs_spend_btc_830k_840k_12 PARTITION OF transaction_outputs_spend_btc_830k_840k
    FOR VALUES FROM (291834553792724992) TO (291838148680351743);
CREATE TABLE transaction_outputs_spend_btc_840k_850k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291838148680351744) TO (291881098353311743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_1 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291838148680351744) TO (291841726388109311);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_2 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291841726388109312) TO (291845304095866879);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_3 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291845304095866880) TO (291848881803624447);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_4 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291848881803624448) TO (291852459511382015);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_5 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291852459511382016) TO (291856037219139583);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_6 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291856037219139584) TO (291859614926897151);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_7 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291859614926897152) TO (291863192634654719);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_8 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291863192634654720) TO (291866770342412287);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_9 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291866770342412288) TO (291870348050169855);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_10 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291870348050169856) TO (291873925757927423);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_11 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291873925757927424) TO (291877503465684991);
CREATE TABLE transaction_outputs_spend_btc_840k_850k_12 PARTITION OF transaction_outputs_spend_btc_840k_850k
    FOR VALUES FROM (291877503465684992) TO (291881098353311743);
CREATE TABLE transaction_outputs_spend_btc_850k_860k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291881098353311744) TO (291924048026271743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_1 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291881098353311744) TO (291884676061069311);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_2 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291884676061069312) TO (291888253768826879);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_3 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291888253768826880) TO (291891831476584447);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_4 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291891831476584448) TO (291895409184342015);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_5 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291895409184342016) TO (291898986892099583);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_6 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291898986892099584) TO (291902564599857151);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_7 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291902564599857152) TO (291906142307614719);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_8 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291906142307614720) TO (291909720015372287);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_9 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291909720015372288) TO (291913297723129855);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_10 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291913297723129856) TO (291916875430887423);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_11 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291916875430887424) TO (291920453138644991);
CREATE TABLE transaction_outputs_spend_btc_850k_860k_12 PARTITION OF transaction_outputs_spend_btc_850k_860k
    FOR VALUES FROM (291920453138644992) TO (291924048026271743);
CREATE TABLE transaction_outputs_spend_btc_860k_870k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291924048026271744) TO (291966997699231743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_860k_870k_default PARTITION OF transaction_outputs_spend_btc_860k_870k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_870k_880k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (291966997699231744) TO (292009947372191743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_870k_880k_default PARTITION OF transaction_outputs_spend_btc_870k_880k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_880k_890k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292009947372191744) TO (292052897045151743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_880k_890k_default PARTITION OF transaction_outputs_spend_btc_880k_890k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_890k_900k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292052897045151744) TO (292095846718111743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_890k_900k_default PARTITION OF transaction_outputs_spend_btc_890k_900k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_900k_910k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292095846718111744) TO (292138796391071743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_900k_910k_default PARTITION OF transaction_outputs_spend_btc_900k_910k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_910k_920k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292138796391071744) TO (292181746064031743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_910k_920k_default PARTITION OF transaction_outputs_spend_btc_910k_920k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_920k_930k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292181746064031744) TO (292224695736991743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_920k_930k_default PARTITION OF transaction_outputs_spend_btc_920k_930k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_930k_940k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292224695736991744) TO (292267645409951743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_930k_940k_default PARTITION OF transaction_outputs_spend_btc_930k_940k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_940k_950k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292267645409951744) TO (292310595082911743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_940k_950k_default PARTITION OF transaction_outputs_spend_btc_940k_950k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_950k_960k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292310595082911744) TO (292353544755871743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_950k_960k_default PARTITION OF transaction_outputs_spend_btc_950k_960k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_960k_970k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292353544755871744) TO (292396494428831743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_960k_970k_default PARTITION OF transaction_outputs_spend_btc_960k_970k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_970k_980k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292396494428831744) TO (292439444101791743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_970k_980k_default PARTITION OF transaction_outputs_spend_btc_970k_980k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_980k_990k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292439444101791744) TO (292482393774751743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_980k_990k_default PARTITION OF transaction_outputs_spend_btc_980k_990k DEFAULT;
CREATE TABLE transaction_outputs_spend_btc_990k_1000k PARTITION OF transaction_outputs_spend_btc
    FOR VALUES FROM (292482393774751744) TO (292525343447711743) partition by range(output_id);
CREATE TABLE transaction_outputs_spend_btc_990k_1000k_default PARTITION OF transaction_outputs_spend_btc_990k_1000k DEFAULT;