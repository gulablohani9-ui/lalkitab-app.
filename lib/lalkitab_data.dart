class LalKitabData {
  static Map<String, dynamic> evaluatePredictions(Map<String, int> chart, int varshphalAge) {
    List<Map<String, String>> reports = [];

    chart.forEach((planet, house) {
      String pred = "";
      String remedy = "";

      switch (planet) {
        case "Mars":
          if (house == 1) {
            pred = "मैदान-ए-जंग: लीडरशिप क्वालिटी, सरकार से सम्बन्ध बने तो ऊँचा पद।"; //[span_18](start_span)[span_18](end_span)
            remedy = "मंगल यहाँ ग्रह फल का है, इसका उपाय न करें। किसी की मध्यस्थता न करें।"; //[span_19](start_span)[span_19](end_span)
          } else if (house == 2) {
            pred = "लंगर लगाने वाला, दुनिया को खाना खिलाने की ताकत। जितना खर्च करेगा उतना धनवान।"; //[span_20](start_span)[span_20](end_span)
            remedy = "साफ नीयत से भण्डारे लगाएं व लोगों को भोजन कराएं।"; //[span_21](start_span)[span_21](end_span)
          } else if (house == 3) {
            pred = "पिंजरे का शेर: खुद के लिए मनहूस मगर दुनिया का भला करने वाला। अमीर माँ-बाप का गरीब बेटा।"; //[span_22](start_span)[span_22](end_span)
            remedy = "तांबे का कड़ा पहनें, परिवार के साथ रहें।"; //[span_23](start_span)[span_23](end_span)
          } else if (house == 4) {
            pred = "पानी में लगी आग (मंगल बद)। माँ, नानी और सास से तल्खी, 28 वर्ष तक सतर्क रहें।"; //[span_24](start_span)[span_24](end_span)
            remedy = "मिट्टी के कुल्हड़ में शहद भरकर श्मशान के पास दबाएं। चौखट पर चांदी का पतरा लगाएं।"; //[span_25](start_span)[span_25](end_span)
          } else if (house == 8) {
            pred = "मंगल बद: मौत का फंदा। छोटे भाई से साझेदारी में नुकसान, काम की शुरुआत जोरदार अंत शून्य।"; //[span_26](start_span)[span_26](end_span)
            remedy = "तवे को पानी के छींटे मारकर रोटी बनाएं। तंदूर की मीठी रोटी कुत्तों को खिलाएं।"; //[span_27](start_span)[span_27](end_span)
          } else {
            pred = "मंगल खाना नं. $house का फलित PDF नियमों के अनुसार लागू होगा।";
            remedy = "मीठा खाएं और दूसरों को भी मीठा खिलाएं।"; //[span_28](start_span)[span_28](end_span)
          }
          break;

        case "Mercury":
          if (house == 1) {
            pred = "राजा मगर खुदगर्ज। हाकिम प्रवृत्ति, 34-36 वर्ष में ससुराल को लाभ।"; //[span_29](start_span)[span_29](end_span)
            remedy = "एक जगह टिक कर काम करें। कनिष्ठा उंगली में स्टील का छल्ला पहनें।"; //[span_30](start_span)[span_30](end_span)
          } else if (house == 3) {
            pred = "थूकने वाला कोढ़ी। 32 दांत वाले रिश्तेदारों पर बुरा असर, बार-बार तबादला।"; //[span_31](start_span)[span_31](end_span)
            remedy = "फिटकरी से दांत साफ करें। ढाक के पत्तों को दूध से धोकर जमीन में दबाएं।"; //[span_32](start_span)[span_32](end_span)
          } else if (house == 8) {
            pred = "कब्र तक की लानत, खुफिया तबाही का फंदा, अचानक चालान या कानूनी नुकसान।"; //[span_33](start_span)[span_33](end_span)
            remedy = "मिट्टी के बर्तन में शहद भरकर जमीन में दबाएं। तांबे के लोटे में मूंग भरकर जल प्रवाह करें।"; //[span_34](start_span)[span_34](end_span)
          } else if (house == 12) {
            pred = "रात की नींद हराम, दगाबाज आदतें। 25वें वर्ष में विवाह गृहस्थी के लिए हानिकारक।"; //[span_35](start_span)[span_35](end_span)
            remedy = "स्टेनलेस स्टील का छल्ला पहनें। कोरा घड़ा जल प्रवाह करें।"; //[span_36](start_span)[span_36](end_span)
          } else {
            pred = "बुध खाना नं. $house का प्रभाव बौद्धिक व व्यापारिक स्थिति तय करेगा।"; //[span_37](start_span)[span_37](end_span)
            remedy = "छोटी कन्याओं का पूजन करें व दुर्गा चालीसा का पाठ करें।"; //[span_38](start_span)[span_38](end_span)[span_39](start_span)[span_39](end_span)
          }
          break;

        case "Moon":
          if (house == 1) {
            pred = "दूध खालिस, मन की शांति, माता से आशीर्वाद लेने पर धन की कभी कमी नहीं।"; //[span_40](start_span)[span_40](end_span)
            remedy = "दूध या पानी का व्यापार न करें। चारपाई के पाये में तांबे की कील लगाएं।"; //[span_41](start_span)[span_41](end_span)
          } else if (house == 7) {
            pred = "लक्ष्मी अवतार, अपनी मेहनत से खजाना भरेगा। 24-25वें वर्ष में विवाह कष्टकारी।"; //[span_42](start_span)[span_42](end_span)
            remedy = "विवाह के समय ससुराल से चांदी लेकर घर में स्थापित करें।"; //[span_43](start_span)[span_43](end_span)
          } else if (house == 12) {
            pred = "रात के वक्त सैलाब, रात की नींद खराब। बाप-दादा की संपत्ति नष्ट होने का भय।"; //[span_44](start_span)[span_44](end_span)
            remedy = "बारिश का पानी कांच की बोतल में घर में रखें। मंदिर में नित्य दर्शन करें।"; //[span_45](start_span)[span_45](end_span)
          } else {
            pred = "चन्द्र खाना नं. $house के अनुसार माता व आमदनी की स्थिति तय होगी।"; //[span_46](start_span)[span_46](end_span)
            remedy = "चांदी की डिब्बी में चावल भरकर रखें।"; //[span_47](start_span)[span_47](end_span)
          }
          break;

        case "Sun":
          if (house == 1) {
            pred = "धर्मी राजा, सरकार से ताल्लुक, 100 वर्ष की लंबी उम्र।"; //[span_48](start_span)[span_48](end_span)
            remedy = "24 वर्ष से पहले सरकारी कार्य से जुड़ें या विवाह समय पर करें।"; //[span_49](start_span)[span_49](end_span)
          } else if (house == 5) {
            pred = "शेरों की जोड़ी, औलाद की तरक्की, मान-सम्मान भरपूर।"; //[span_50](start_span)[span_50](end_span)
            remedy = "लाल मुंह के बंदरों को गुड़-चना खिलाएं।"; //[span_51](start_span)[span_51](end_span)
          } else if (house == 10) {
            pred = "शनि के घर में सूर्य: चालाकी से काम लें, पिता की छत्रछाया में लाभ।"; //[span_52](start_span)[span_52](end_span)
            remedy = "सिर ढक कर रखें। 43 दिन तांबे का सिक्का जल प्रवाह करें।"; //[span_53](start_span)[span_53](end_span)
          } else {
            pred = "सूर्य खाना नं. $house का फल राजदरबार व पिता के अनुसार फलित होगा।"; //[span_54](start_span)[span_54](end_span)
            remedy = "तांबे का चौरस टुकड़ा पास रखें।"; //[span_55](start_span)[span_55](end_span)
          }
          break;

        case "Saturn":
          if (house == 1) {
            pred = "नीच शनि: वैराग्य, 36 वर्ष की उम्र के बाद ही स्थायी कमाई शुरू होगी।"; //[span_56](start_span)[span_56](end_span)
            remedy = "बड़ के पेड़ पर मीठा दूध चढ़ाएं और गीली मिट्टी का तिलक लगाएं।"; //[span_57](start_span)[span_57](end_span)
          } else if (house == 8) {
            pred = "शनि अपने मुख्यालय में: खुद के लिए ठीक, मगर मकान बनाने पर परेशानियां।"; //[span_58](start_span)[span_58](end_span)
            remedy = "चांदी का चौरस टुकड़ा रखें। 36 वर्ष से पहले खुद का मकान न बनाएं।"; //[span_59](start_span)[span_59](end_span)
          } else if (house == 10) {
            pred = "कोरा कागज: जैसा कर्म वैसा फल। 48 वर्ष से पहले नया मकान न बनाएं।"; //[span_60](start_span)[span_60](end_span)
            remedy = "शराब व मांस से पूर्ण परहेज रखें। एक जगह बैठकर काम करें।"; //[span_61](start_span)[span_61](end_span)
          } else {
            pred = "शनि खाना नं. $house के प्रभाव से आयु व न्याय पक्ष मजबूत रहेगा।"; //[span_62](start_span)[span_62](end_span)
            remedy = "भैरों जी को दूध चढ़ाएं और काले कुत्ते को रोटी दें।"; //[span_63](start_span)[span_63](end_span)
          }
          break;

        case "Jupiter":
          if (house == 1) {
            pred = "राजगुरु: इल्म खजाने की चाबी। डिग्री हासिल करने पर नवाबी, अन्यथा फकीरी।"; //[span_64](start_span)[span_64](end_span)
            remedy = "जिस विषय की डिग्री हो उसी से संबंधित काम करें। केसर का तिलक लगाएं।"; //[span_65](start_span)[span_65](end_span)
          } else if (house == 2) {
            pred = "जगतगुरु: जितना दान करेगा उतनी धन-दौलत बढ़ेगी। सोने का काम न करें।"; //[span_66](start_span)[span_66](end_span)
            remedy = "चने की दाल पीले कपड़े में बांधकर धर्मस्थान में दें।"; //[span_67](start_span)[span_67](end_span)
          } else if (house == 7) {
            pred = "गृहस्थ में साधु स्वभाव। घर में मंदिर रखने पर औलाद से दूरी या तनाव।"; //[span_68](start_span)[span_68](end_span)
            remedy = "घर में घंटी बजाने वाला मंदिर न रखें। चांदी की डिब्बी में चावल रखें।"; //[span_69](start_span)[span_69](end_span)
          } else {
            pred = "गुरु खाना नं. $house आध्यात्मिक व आर्थिक संतुलन तय करेगा।"; //[span_70](start_span)[span_70](end_span)
            remedy = "माथे और नाभि पर नित्य केसर का तिलक लगाएं।"; //[span_71](start_span)[span_71](end_span)
          }
          break;

        case "Venus":
          if (house == 1) {
            pred = "हुस्नपरस्त व शौकीन। 25वें वर्ष में विवाह करने पर धन व स्त्री की हानि।"; //[span_72](start_span)[span_72](end_span)
            remedy = "दही से स्नान करें और गोमूत्र का सेवन करें।"; //[span_73](start_span)[span_73](end_span)
          } else if (house == 6) {
            pred = "नीच शुक्र: पत्नी को रानी बनाकर रखने पर ही 12 गुना धन की आवक होगी।"; //[span_74](start_span)[span_74](end_span)
            remedy = "पत्नी के बालों में सोने का क्लिप लगवाएं। नंगे पैर न रहने दें।"; //[span_75](start_span)[span_75](end_span)
          } else if (house == 12) {
            pred = "उच्च शुक्र: कामधेनु गाय। पत्नी साक्षात मदद की मूरत होगी।"; //[span_76](start_span)[span_76](end_span)
            remedy = "गौदान करें व पत्नी के हाथ से नीला फूल जमीन में दबवाएं।"; //[span_77](start_span)[span_77](end_span)
          } else {
            pred = "शुक्र खाना नं. $house सांसारिक सुख व आकर्षण को नियंत्रित करेगा।"; //[span_78](start_span)[span_78](end_span)
            remedy = "काली गाय को हरा चारा खिलाएं।"; //[span_79](start_span)[span_79](end_span)
          }
          break;

        case "Rahu":
          if (house == 1) {
            pred = "तख्त थर्राने वाला हाथी, चलती गाड़ी में अचानक रोड़ा अटकाने की प्रवृत्ति।"; //[span_80](start_span)[span_80](end_span)
            remedy = "मेहनत की कमाई खाएं, कोई फर्जी स्कीम न चलाएं। चांदी का कड़ा पहनें।"; //[span_81](start_span)[span_81](end_span)
          } else if (house == 5) {
            pred = "कड़कती बिजली: औलाद के जन्म पर सावधानी जरूरी। पराई स्त्री से दूर रहें।"; //[span_82](start_span)[span_82](end_span)
            remedy = "60 ग्राम चांदी का ठोस हाथी (सूंड नीचे) घर में स्थापित करें।"; //[span_83](start_span)[span_83](end_span)
          } else if (house == 12) {
            pred = "शेखचिल्ली ख्यालात, दिन में सपने देखना, रात की नींद में फिजूलखर्ची।"; //[span_84](start_span)[span_84](end_span)
            remedy = "रसोई में बैठकर गर्म-गर्म रोटी खाएं। सौंफ का तकिया सिरहाने रखें।"; //[span_85](start_span)[span_85](end_span)
          } else {
            pred = "राहु खाना नं. $house अप्रत्याशित घटनाएं और ससुराल पक्ष तय करेगा।"; //[span_86](start_span)[span_86](end_span)
            remedy = "सफाई कर्मचारी को मसूर दाल या सिक्का दान दें।"; //[span_87](start_span)[span_87](end_span)
          }
          break;

        case "Ketu":
          if (house == 1) {
            pred = "औलाद की चिंता में लगा रहने वाला, सफर की अधिकता, यात्रा में नुकसान।"; //[span_88](start_span)[span_88](end_span)
            remedy = "कानों में सोना पहनें व माथे पर केसर तिलक लगाएं।"; //[span_89](start_span)[span_89](end_span)
          } else if (house == 6) {
            pred = "शेरकद खूंखार कुत्ता: भाई-दोस्तों के काम आने वाला, रीढ़ की हड्डी में विकार।"; //[span_90](start_span)[span_90](end_span)
            remedy = "बाएं हाथ में सोने की अंगूठी पहनें। काला कुत्ता पालें।"; //[span_91](start_span)[span_91](end_span)
          } else if (house == 8) {
            pred = "छत पर रोने वाला कुत्ता: औलाद और कमर-पेशाब से जुड़ी समस्याएं।"; //[span_92](start_span)[span_92](end_span)
            remedy = "काला-सफेद कंबल मंदिर में दान दें। कान छिदवाएं।"; //[span_93](start_span)[span_93](end_span)
          } else {
            pred = "केतु खाना नं. $house पुत्र संतान और यात्राओं के योग बनाएगा।"; //[span_94](start_span)[span_94](end_span)
            remedy = "कुत्तों को मीठी या फीकी रोटी खिलाएं।"; //[span_95](start_span)[span_95](end_span)
          }
          break;
      }

      reports.add({
        "planet": planet,
        "house": house.toString(),
        "pred": pred,
        "remedy": remedy,
      });
    });

    return {"reports": reports};
  }

  static Map<String, int> calculateVarshphal(Map<String, int> birthChart, int age) {
    Map<String, int> vChart = {};
    birthChart.forEach((planet, house) {
      // Lal Kitab Varshphal Progression Formula
      int newHouse = ((house - 1 + (age % 12)) % 12) + 1;
      vChart[planet] = newHouse;
    });
    return vChart;
  }
}
