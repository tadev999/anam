class ZenConstants {
  // Phân loại Châm ngôn theo Trạng thái tâm lý (Tâm trạng)
  static const Map<String, List<String>> emotionalAffirmations = {
    "burnout": [
      "Sự tồn tại của bạn đã là một món quà. Không cần chứng minh gì cả.",
      "Bạn không cần phải chạy thật nhanh. Đi chậm lại cũng là một sự tiến bộ.",
      "Thành công lớn nhất của hôm nay chỉ đơn giản là bạn đã chăm sóc tốt cho bản thân.",
      "Dịu dàng với chính mình hôm nay. Bạn đang làm rất tốt.",
      "Nghỉ ngơi cũng là một hình thức chuẩn bị cho hành trình phía trước. Đừng cảm thấy tội lỗi.",
      "Bạn là một con người (human being), không phải một cái máy làm việc (human doing). Lắng nghe hơi thở của mình chính là cách bắt đầu lại.",
      "Không cần phải làm mọi thứ thật hoàn hảo. Chấp nhận sự dang dở của hôm nay là một nét đẹp bình dị.",
      "Hơi thở của bạn không vội vã. Nhịp tim của bạn không vội vã. Bạn cũng không cần phải vội vã.",
      "Cho phép bản thân tạm dừng lại là biểu hiện lớn nhất của sự dũng cảm và lòng tự trắc ẩn.",
      "Có những ngày, việc duy nhất bạn cần làm là hít vào thật sâu và thở ra thật nhẹ.",
      "Mọi hoa cỏ đều có mùa nở riêng. Bạn không cần phải nở rộ vào mọi khoảnh khắc.",
      "Sự kiệt sức hôm nay là thông tin từ cơ thể nói rằng bạn đã gồng gánh quá nhiều. Cơ thể cần được lắng nghe và nghỉ ngơi.",
      "Bạn không phải là năng suất công việc của mình. Giá trị của bạn đứng vững khi mọi thứ dừng lại.",
      "Buông lỏng đôi vai đang gồng cứng. Thế giới này sẽ không sụp đổ khi bạn nghỉ ngơi một ngày.",
      "Không cần so sánh chương 1 của mình với chương 20 của người khác. Mỗi người có một nhịp sinh học riêng.",
      "Kiệt sức không phải là thất bại. Nó là tiếng còi báo hiệu bạn cần quay về trú ẩn trong chính mình.",
      "Bạn đủ rồi — ngay trong trạng thái mệt mỏi, rã rời và chưa hoàn thành công việc của hôm nay.",
      "Hôm nay, việc từ chối những kỳ vọng không thuộc về bạn sẽ bảo vệ năng lượng tinh thần của chính bạn.",
      "Trả tự do cho bản thân khỏi áp lực phải luôn tỏ ra mạnh mẽ và có ích.",
      "Một giấc ngủ sâu, một cốc nước ấm — những hành động nhỏ này chính là triết học chữa lành thiết thực nhất.",
      "Bạn không cần cứu thế giới. Sưởi ấm cho chính bản thân mình trước đã là đủ rồi.",
      "Những việc chưa làm xong có thể nằm yên đó. Ngày mai sẽ tự có ánh sáng của ngày mai.",
      "Đôi chân mỏi mệt hôm nay xứng đáng được nâng niu. Lùi lại một bước cũng là một sự lựa chọn tốt.",
      "Cơn kiệt sức này chỉ là thời tiết trong lòng. Nó là tạm thời, không định nghĩa con người bạn.",
      "Không có gì đáng hổ thẹn khi nói 'tôi mệt rồi'. Đó là lúc lòng tự trắc ẩn lên tiếng.",
      "Tháo bỏ lớp mặt nạ bận rộn. Bạn là ai khi không có công việc để làm?",
      "Đứng yên giữa dòng chảy hối hả cũng là một loại bản lĩnh. Bạn được quyền đứng yên.",
      "Năng lượng tinh thần là có hạn. Dành những phần còn lại hôm nay để ôm lấy chính mình.",
      "Sự chấp nhận cơ thể mệt mỏi này là bước đầu tiên để khôi phục sức mạnh nội sinh.",
      "Khi bạn ngừng cố gắng quá sức, bạn mới thực sự thấy mình đang sống."
    ],
    "overthinking": [
      "Chúng ta chỉ có thể kiểm soát cánh buồm, không thể kiểm soát hướng gió. Học cách buông bỏ là cách duy nhất.",
      "Mọi cảm xúc tiêu cực chỉ như mây trôi qua bầu trời tâm trí. Trời rồi sẽ lại xanh.",
      "Quá khứ đã qua, tương lai chưa tới. Sức mạnh của bạn nằm ngay ở giây phút này.",
      "Hôm nay, mọi thứ diễn ra tự nhiên là điều tốt nhất. Mọi sự sắp đặt đều có lý do của nó.",
      "Suy nghĩ chỉ là những làn sóng trên mặt hồ tâm trí. Hồ nước sẽ tự phẳng lặng khi không có gió.",
      "Bạn không phải là suy nghĩ của bạn. Bạn là người đang quan sát những suy nghĩ đó trôi qua.",
      "Suy nghĩ giống như những đám mây. Bạn không cần phải nắm giữ chúng, chúng sẽ tự bay đi.",
      "Mọi lo âu về ngày mai đều là vay mượn từ tương lai một nỗi buồn chưa chắc đã xảy ra.",
      "Bước đi đầu tiên luôn là bước đi quan trọng nhất. Tập trung vào bước chân hiện tại thay vì toàn bộ hành trình giúp ta vững vàng hơn.",
      "Nhìn ngắm một bông hoa hay một tách trà nóng sẽ kéo tâm trí về với cơ thể vật lý của bạn lúc này.",
      "Mọi câu hỏi không nhất thiết phải có câu trả lời ngay lập tức. Sự mơ hồ cũng là một phần của cuộc sống.",
      "Tâm trí đang cố giải quyết những thứ nằm ngoài tầm kiểm soát của nó. Đưa nó về với hiện tại giúp khôi phục sự yên bình.",
      "Những suy nghĩ rối ren chỉ là thông tin cho thấy bạn đang rất quan tâm đến cuộc sống, không phải kẻ thù.",
      "Bạn không cần phải chuẩn bị cho mọi kịch bản tồi tệ nhất. Bạn đủ khả năng ứng phó khi chúng thực sự xảy ra.",
      "Tách biệt giữa suy nghĩ của bạn và sự thật khách quan ngoài kia là điều cần thiết lúc này.",
      "Một suy nghĩ không thể làm tổn thương bạn trừ khi bạn tin vào nó và nuôi dưỡng nó.",
      "Hôm nay, tôi chọn không tranh luận với các kịch bản vẽ ra trong đầu. Tôi chọn cảm nhận thực tại.",
      "Không có quyết định nào hoàn hảo tuyệt đối. Mọi ngã rẽ đều chứa đựng những trải nghiệm riêng.",
      "Trả tự do cho tâm trí khỏi ảo tưởng rằng nghĩ nhiều hơn sẽ giải quyết được tất cả.",
      "Hít một hơi thật sâu. Đếm từ một đến năm. Bạn đang ở đây, an toàn trong khoảnh khắc này.",
      "Những gì xảy ra bên ngoài là vô thường. Pháo đài tâm lý duy nhất nằm ở sự bình yên nội tâm.",
      "Để suy nghĩ tự đối thoại với chính nó, còn bạn tiếp tục thưởng thức bữa tối.",
      "Bạn đang dùng highlight reel của người khác để so sánh với những ngổn ngang sau cánh gà của mình.",
      "Đứng trên cương vị người quan sát. Xem suy nghĩ như những dòng xe cộ trôi qua, đừng nhảy vào làn đường đó.",
      "Tương lai là bức tranh chưa vẽ. Vẽ nó bằng lo âu chỉ làm hỏng đi tấm toan của ngày hôm nay.",
      "Mỗi lần bạn chọn dừng phân tích và tập trung vào một hành động nhỏ, bạn đã tự lấy lại quyền kiểm soát.",
      "Đừng cố sửa chữa mọi suy nghĩ méo mó. Chỉ cần nhận ra sự méo mó đó và mỉm cười đi qua.",
      "Sự mơ hồ của cuộc đời không phải là mối đe dọa, nó là khoảng không cho những khả năng mới.",
      "Bạn đủ rồi — kể cả khi tâm trí bạn hôm nay vẫn chưa tìm được sự bình yên tuyệt đối.",
      "Trả mọi lo lắng về cho vũ trụ. Đêm nay, bạn chỉ cần ngủ một giấc thật ngon."
    ],
    "lonely": [
      "Một hành động tử tế nhỏ bé có thể thắp sáng cả một ngày u ám.",
      "Sâu thẳm bên trong bạn luôn có một nguồn sức mạnh tự thân chưa được khai phá.",
      "Bạn không cô đơn, vũ trụ này đang thở cùng nhịp với bạn.",
      "Bão tố ngoài kia dữ dội đến đâu, sâu thẳm trong lòng vẫn luôn có một nơi tĩnh lặng.",
      "Kết nối chân thành bắt đầu từ việc bạn thấu hiểu và chấp nhận chính sự cô đơn của mình.",
      "Có một bếp lửa ấm áp luôn chờ đón bạn ở đây, trong chốn bình yên này.",
      "Sự cô đơn là khoảng lặng quý giá để bạn làm quen và kết bạn lại với chính con người sâu thẳm của mình.",
      "Mỗi người là một hòn đảo nhỏ, nhưng bên dưới đại dương, chúng ta đều chung một thềm lục địa.",
      "Trò chuyện dịu dàng với nỗi cô đơn như một người bạn cũ lâu ngày gặp lại.",
      "Cảm giác cô độc chỉ là một lời nhắc nhở rằng trái tim bạn đang khao khát những kết nối chân thành.",
      "Luôn có những tâm hồn âm thầm đồng điệu với bạn qua từng trang viết ẩn danh quanh Bếp Lửa này.",
      "Sự cô đơn không nói rằng bạn vô giá trị, nó chỉ cho thấy bạn đang thiếu những kết nối thật lòng.",
      "Bạn cần người khác không phải để được cứu rỗi, mà để nhìn thấy rõ hơn những gì đã có trong bạn.",
      "Làm một điểm tựa vững chãi cho chính mình trước khi tìm kiếm một gậy chống ở bên ngoài.",
      "Cô đơn giữa đám đông là vì bạn đang cố đóng một vai diễn không thuộc về mình. Trở về làm bạn là đủ rồi.",
      "Mọi người quanh bếp lửa này đều đang mang những vết sẹo riêng. Bạn không lẻ loi trong bóng tối.",
      "Khi bạn học được cách ở một mình mà không cô độc, bạn đã nắm giữ chiếc chìa khóa tự do nội tâm.",
      "Một cái ôm thấu cảm gửi đi từ đây có thể sưởi ấm cho ai đó, và đồng thời sưởi ấm chính bạn.",
      "Nỗi cô đơn của hôm nay là tín hiệu để bạn quay vào trong chăm sóc đứa trẻ đang bị lãng quên.",
      "Trải lòng ẩn danh để thấy rằng những nỗi sợ thầm kín nhất của bạn cũng là nỗi sợ của bao người.",
      "Đứng yên trong yên lặng của phòng trống. Bạn vẫn trọn vẹn và có giá trị vô điều kiện.",
      "Sự cô đơn giống như mùa đông. Nó lạnh giá nhưng cần thiết để các hạt mầm bên trong chuẩn bị nảy nở.",
      "Bạn đủ rồi — kể cả khi xung quanh bạn lúc này không có một ai lắng nghe.",
      "Gửi đi hơi ấm vô danh chính là cách bạn nhắc nhở bản thân rằng mình vẫn có khả năng yêu thương.",
      "Mối quan hệ sâu sắc nhất cuộc đời là mối quan hệ giữa bạn với chính bản thân mình.",
      "Không cần phải cố gắng hòa nhập bằng mọi giá. Chấp nhận sự khác biệt của bản thân là bước đầu chữa lành.",
      "Nỗi cô đơn hôm nay là thông tin, không phải bản án chung thân định nghĩa cuộc đời bạn.",
      "Để nỗi buồn cô đơn chảy trôi tự nhiên qua hơi thở. Nó sẽ tự biến đổi khi bạn không chống cự.",
      "Quanh bếp lửa chung này, chúng ta được nhìn thấy nhau trong trạng thái chân thật và nguyên bản nhất.",
      "Khi bạn tự thương lấy mình, sự cô đơn tự khắc chuyển hóa thành sự tĩnh lặng ngọt ngào."
    ],
    "empty": [
      "Trống rỗng không có nghĩa là vô giá trị. Đó là khoảng trống để bạn gieo trồng những hạt mầm mới.",
      "Để tâm trí rỗng lặng như một căn phòng đón nhận làn gió mát buổi sớm mai.",
      "Khi không biết đi đâu, đó là lúc bạn được tự do lựa chọn mọi con đường.",
      "Chấp nhận sự trống trải của thực tại chính là bước đầu tiên để chạm vào sự tự do tối hậu.",
      "Giống như tre rỗng ruột mới tạo nên tiếng sáo du dương, tâm hồn tĩnh lặng mới nghe được âm thanh cuộc sống.",
      "Như một tờ giấy trắng hay một chiếc tách rỗng, sự trống trải mở ra khả năng chứa đựng vô hạn.",
      "Không có gì để mất cũng có nghĩa là bạn đang đứng trước cơ hội để bắt đầu lại mọi thứ theo cách mới.",
      "Cho phép mình được lặng lẽ tồn tại mà không cần gắn nhãn hay định nghĩa bản thân là ai.",
      "Trống rỗng chỉ là một khoảng lặng giữa hai bản nhạc, giúp âm thanh tiếp theo trở nên trong trẻo hơn.",
      "Trong sự tĩnh lặng không màu sắc, bạn sẽ tìm thấy sự tự do nguyên bản nhất của tâm hồn.",
      "Nỗi trống trải hôm nay là thông tin báo hiệu những giá trị bên ngoài đã không còn nuôi dưỡng được bạn.",
      "Không cần vội vã lấp đầy khoảng trống bằng dopamine ngắn hạn. Chỉ cần ngồi yên và cảm nhận nó một lát.",
      "Bạn là ai khi không có mục tiêu để chạy theo, không có kỳ vọng để gồng gánh?",
      "Sự trống rỗng là lời mời gọi quay về với những giá trị tự thân vững chắc nhất.",
      "Không làm gì mà không cảm thấy tội lỗi — đó là lúc bạn chấp nhận giá trị vô điều kiện của sự sinh tồn.",
      "Mọi thứ có thể trôi tuột đi hôm nay. Một tâm hồn rỗng lặng là một tâm hồn không bị giam cầm.",
      "Khi chiếc cúp trống không, nó mới có thể đón nhận nguồn nước mới trong lành.",
      "Trống rỗng không phải là căn bệnh cần chữa trị. Nó là khoảng nghỉ cần thiết trước chu kỳ sinh trưởng mới.",
      "Hôm nay, tôi chọn không cố tỏ ra hạnh phúc hay bận rộn. Tôi chọn ở lại với khoảng lặng này.",
      "Ý nghĩa không được ban sẵn từ vũ trụ. Nó được gieo từ những hạt mầm nhỏ nhất khi lòng bạn đã rỗng.",
      "Bạn đủ rồi — ngay cả khi bạn cảm thấy mình không có mục đích hay động lực gì hôm nay.",
      "Nhìn ngắm khoảng không giữa các kẽ lá sẽ thấy chính khoảng không đó làm nên vẻ đẹp của vòm cây.",
      "Đừng sợ hãi sự vô vị của thực tại. Sự chân thật thường nằm ở những khoảnh khắc giản dị nhất.",
      "Một ngày không đạt được gì vẫn là một ngày trọn vẹn nếu bạn thấy mình đang thở và đang sống thật.",
      "Mọi sự sáng tạo vĩ đại đều bắt đầu từ một khoảng không trống rỗng và im lặng tuyệt đối.",
      "Trả tự do cho bản thân khỏi áp lực phải luôn cảm thấy hào hứng và tràn trề năng lượng.",
      "Lòng rỗng lặng như mặt hồ không gió, phản chiếu bầu trời đêm với tất cả sự chân thật của nó.",
      "Sự trống trải hôm nay chỉ ra rằng bạn cần những nguồn dinh dưỡng sâu sắc hơn cho tâm hồn.",
      "Cảm giác vô định là khởi đầu của sự tự do. Bạn được quyền đi bất cứ hướng nào từ điểm không này.",
      "Mỉm cười chào đón khoảng trống. Đó là nơi bạn được là chính mình mà không cần bất kỳ chiếc mặt nạ nào."
    ],
    "peaceful": [
      "Bình yên không phải là một điểm đến, mà là cách bạn bước đi trong cuộc đời.",
      "Nhìn sâu vào thiên nhiên, bạn sẽ thấu hiểu mọi thứ một cách sâu sắc hơn.",
      "Mỉm cười với hiện tại, trân trọng những điều giản dị quanh mình hôm nay.",
      "Mọi khoảnh khắc trôi qua đều là độc nhất vô nhị. Thưởng thức nó trọn vẹn chính là trân trọng sự sống.",
      "Khi tâm ta bình yên, thế giới xung quanh cũng tự khắc trở nên hiền hòa.",
      "Bình yên không nằm ở một nơi không có tiếng ồn, mà nằm ở sự tĩnh lặng ngay giữa những xáo động.",
      "Trân trọng tia nắng ban mai chiếu qua khung cửa, hay tiếng lá rơi xào xạc bên thềm nhà.",
      "Tâm tĩnh thì nước trong. Mọi thứ lắng xuống tự nhiên như bụi đất trôi về với đất.",
      "Hạnh phúc đơn giản là thấy mình vẫn đang sống, đang thở và được cảm nhận thế giới này.",
      "Khi bạn ngừng tìm kiếm sự hoàn hảo bên ngoài, bạn sẽ thấy sự trọn vẹn trong chính những điều không hoàn hảo.",
      "Bình yên thực sự bắt đầu khi bạn đồng ý sống chung với những gì chưa trọn vẹn của chính mình.",
      "Lòng mình tự do như gió, không vướng bận bởi quá khứ, không lo sợ trước tương lai.",
      "Khoảnh khắc thật là khi bạn không cần phải chứng minh bất kỳ điều gì với bất kỳ ai.",
      "Nhìn sâu vào tách trà ấm. Cảm nhận hơi nóng tỏa ra. Bạn đang ở đây, trọn vẹn và bình yên.",
      "Không có cơn bão nào kéo dài mãi mãi. Sự bình yên bên trong là mỏ neo giữ bạn đứng vững.",
      "Khi bạn chấp nhận số phận với sự bình thản tối đa (Amor Fati), mọi biến cố chỉ là chất liệu để trưởng thành.",
      "Sự tĩnh lặng giữa lòng thành phố không nằm ở không gian, nó nằm ở thái độ đón nhận của bạn.",
      "Bạn đủ rồi — không cần thêm bất kỳ điều kiện nào để được quyền cảm thấy bình an ngay lúc này.",
      "Mỉm cười trước những điều không như ý. Chấp nhận sự vô thường là chìa khóa của tự do nội tâm.",
      "Một hành động nhỏ làm với sự chú tâm trọn vẹn chính là một nghi lễ nuôi dưỡng tâm hồn.",
      "Thay vì đuổi theo những kích thích dopamine ngắn hạn, việc nuôi dưỡng những bình lặng bền bỉ sâu bên trong mang lại giá trị lâu dài hơn.",
      "Nhìn mọi thứ trôi qua với tâm thế người lữ hành. Không chiếm hữu, không phán xét, chỉ trân trọng.",
      "Sự thấu hiểu bản thân là cội nguồn của mọi sự yên bình đích thực.",
      "Để lại sau lưng những ồn ào của thế giới số. Lắng nghe tiếng chim hót bên thềm.",
      "Bạn có giá trị vô điều kiện. Nhận thức này mang lại sự giải thoát lớn nhất khỏi mọi lo âu.",
      "Cơ thể và tâm trí hòa làm một khi ta chú tâm vào từng bước đi chạm nhẹ trên mặt đất.",
      "Khi bạn ngừng so sánh cuộc đời mình với người khác, bình yên sẽ tự gõ cửa tìm về.",
      "Nỗi buồn hay niềm vui đều là những vị khách ghé thăm. Đối đãi với chúng bằng lòng hiếu khách bình thản giúp lòng nhẹ nhàng hơn.",
      "Cảm ơn những khoảng lặng tĩnh mịch của đêm nay, nơi bạn được hòa nhịp với hơi thở của đất trời.",
      "Thứ bạn đang tìm kiếm không nằm ở phía trước. Nó đã có trong bạn — đang chờ được nhận ra."
    ]
  };

  // Danh sách phẳng để duy trì khả năng tương thích ngược
  static final List<String> dailyAffirmations = emotionalAffirmations.values.expand((list) => list).toList();

  // Danh sách các hành động nhỏ (Micro-offerings) chữa lành phong phú
  static const List<Map<String, dynamic>> microOfferings = [
    {
      "id": "water",
      "title": "Uống một ly nước đầy",
      "description": "Uống thật chậm rãi, cảm nhận sự tươi mát thấm vào từng tế bào cơ thể.",
      "duration": "1 phút",
      "points": 5,
      "category": "body",
      "icon": "water_drop",
    },
    {
      "id": "breathe",
      "title": "5 hơi thở định tâm sâu",
      "description": "Hít vào bụng phình nhẹ, thở ra bụng xẹp dần. Tập trung hoàn toàn vào luồng khí.",
      "duration": "2 phút",
      "points": 5,
      "category": "mind",
      "icon": "air",
    },
    {
      "id": "tidy_desk",
      "title": "Dọn dẹp lại góc làm việc",
      "description": "Sắp xếp lại 3 món đồ trên bàn để tạo không gian ngăn nắp và thoáng đãng mới.",
      "duration": "5 phút",
      "points": 10,
      "category": "body",
      "icon": "cleaning_services",
    },
    {
      "id": "gratitude_msg",
      "title": "Gửi một tin nhắn cảm ơn",
      "description": "Gửi lời cảm ơn chân thành đến một người bạn hoặc người thân không vì lý do cụ thể nào.",
      "duration": "3 phút",
      "points": 15,
      "category": "soul",
      "icon": "sms",
    },
    {
      "id": "nature_look",
      "title": "Ngắm nhìn một nhành cây",
      "description": "Nhìn ra cửa sổ, tập trung quan sát một nhành lá hay đóa hoa đu đưa trước gió trong 2 phút.",
      "duration": "2 phút",
      "points": 5,
      "category": "mind",
      "icon": "yard",
    },
    {
      "id": "stretch",
      "title": "Vươn vai thả lỏng cơ thể",
      "description": "Đứng dậy vươn người cao hết cỡ, xoay nhẹ cổ và khớp vai để giải phóng stress tích tụ.",
      "duration": "3 phút",
      "points": 8,
      "category": "body",
      "icon": "accessibility",
    },
    {
      "id": "confess_burn",
      "title": "Gửi nỗi lo vào hư vô",
      "description": "Viết ra 1 điều làm bạn mệt mỏi nhất hôm nay vào 'Khoảng Buông' và gửi nó vào hư vô.",
      "duration": "3 phút",
      "points": 10,
      "category": "mind",
      "icon": "cloud_queue",
    },
    {
      "id": "empathy_hug",
      "title": "Gửi một cái ôm vô danh",
      "description": "Vào khu vực 'Bếp Lửa Chung', đọc tâm sự của một người lạ và nhấn nút 'Sưởi ấm' họ.",
      "duration": "2 phút",
      "points": 15,
      "category": "soul",
      "icon": "favorite",
    },
  ];

  // Danh sách 60 câu châm ngôn sưởi ấm cho Bếp lửa sưởi ấm ở HomeView
  static const List<String> hearthQuotes = [
    "Hôm nay, dù thế giới ngoài kia có xô bồ và lạnh lẽo thế nào, bạn luôn có một chốn nương tựa ở đây.",
    "Bạn không cần phải luôn tỏ ra mạnh mẽ. Đôi khi, chấp nhận sự yếu đuối của mình mới là bản lĩnh thực sự.",
    "Hơi ấm của bếp lửa này được thắp lên từ chính những tổn thương đang được chữa lành của bạn.",
    "Một ngày bình thường trôi qua không có nghĩa là vô ích. Tồn tại một cách bình yên đã là một thành tựu lớn.",
    "Thế giới ngoài kia đo lường bạn bằng thành tích, còn ở đây, chúng tôi trân trọng sự hiện diện chân thật của bạn.",
    "Bạn đủ rồi — ngay trong khoảnh khắc này, với tất cả những ngổn ngang và những điều chưa hoàn thiện.",
    "Những ồn ào của ngày hôm nay có thể lắng xuống. Đêm nay, bạn chỉ cần ở lại với hơi ấm của chính mình.",
    "Sự bình yên không nằm ở việc trốn chạy giông bão, mà nằm ở việc tìm thấy mỏ neo vững chắc ngay bên trong bạn.",
    "Đừng để tiếng ồn bên ngoài lấn át đi những tiếng nói thầm thì, chân thật nhất từ con người sâu thẳm của bạn.",
    "Mỗi vết sẹo bạn mang theo đều là bằng chứng cho thấy bạn đã dũng cảm đi qua những ngày giông bão.",
    "Bếp lửa này không phán xét bạn. Cởi bỏ chiếc mặt nạ bận rộn và ngồi xuống sưởi ấm đôi bàn tay.",
    "Có những ngày, việc duy nhất bạn cần làm là hít vào thật sâu và thở ra thật nhẹ để nhận ra mình đang sống.",
    "Bạn là người lữ hành trên con đường của riêng mình. Không có người đi trước, không có người đi sau, chỉ có bạn.",
    "Nhìn ngắm ánh lửa bập bùng và nhận ra rằng: Mọi nỗi đau rồi cũng sẽ hóa nhạt và trôi vào hư vô.",
    "Giá trị của bạn là vô điều kiện. Không một ai, không một thành công hay thất bại nào có thể định nghĩa được bạn.",
    "Học cách trân trọng những góc tối, những ngày buồn bã giúp tạo nên sự trọn vẹn của bạn.",
    "Sự kết nối chân thành nhất bắt đầu từ việc bạn biết cách dịu dàng ôm lấy nỗi cô đơn của chính mình.",
    "Một hành động nhỏ chăm sóc bản thân hôm nay là minh chứng rõ nhất cho việc bạn đang trân trọng sự sống này.",
    "Không có con đường nào là sai lầm nếu nó đưa bạn trở về gần hơn với con người nguyên bản của mình.",
    "Bạn không đơn độc. Luôn có những tâm hồn âm thầm ngồi quanh bếp lửa này, chia sẻ cùng tần số cảm xúc với bạn.",
    "Trà ấm đã pha, bếp lửa đã đượm. Tâm trí xứng đáng được nghỉ ngơi một lúc sau một ngày dài.",
    "Nhịp sống hối hả ngoài kia là của thế giới. Nhịp thở tĩnh lặng này là của riêng bạn.",
    "Sự dịu dàng với bản thân cũng giống như cách bạn dịu dàng với một người bạn đang gặp khó khăn.",
    "Cơn mưa ngoài cửa sổ rồi sẽ tạnh, và những xáo động trong lòng bạn cũng sẽ tự tìm về trạng thái bình yên.",
    "Mọi sự thay đổi sâu sắc nhất đều bắt đầu một cách lặng lẽ từ bên trong, không cần ai nhìn thấy.",
    "Bạn không cần phải giải thích hay chứng minh giá trị của mình với bất kỳ ai. Bạn sinh ra là đã đủ giá trị.",
    "Để cuộc đời trôi chảy tự nhiên. Đôi khi, buông bỏ việc kiểm soát chính là cách tìm thấy sự tự do.",
    "Những suy nghĩ ngổn ngang hôm nay chỉ là thời tiết nhất thời. Bầu trời tâm trí bạn vẫn luôn xanh.",
    "Cảm ơn bạn vì đã kiên trì đi qua ngày hôm nay, kể cả khi có những lúc bạn tưởng chừng muốn bỏ cuộc.",
    "Dành ra vài phút yên lặng không làm gì cả. Đó là món quà tuyệt vời nhất bạn có thể tự tặng mình lúc này.",
    "Đừng so sánh behind-the-scenes ngổn ngang của mình với highlight reel lấp lánh của người khác.",
    "Mọi cảm xúc khó chịu chỉ là thông tin cho thấy bạn đang cần được yêu thương và vỗ về nhiều hơn.",
    "Sự trống trải trong lòng không phải là điều đáng sợ, đó là khoảng trống để bạn gieo những hạt mầm mới.",
    "Trân trọng cả những ngày bản thân cảm thấy mệt mỏi hay vô dụng nhất, vì đó là lúc tâm hồn đang cần nghỉ ngơi.",
    "Bếp lửa này luôn cháy sáng bằng sự đồng cảm thầm lặng của những tâm hồn cùng tần số.",
    "Đứng yên giữa dòng người vội vã cũng là một loại tự do. Bạn không nhất thiết phải cuốn theo họ.",
    "Giá trị của bạn không tăng khi bạn làm tốt và không giảm khi bạn phạm sai lầm. Bạn là duy nhất.",
    "Cơ thể này xứng đáng nhận được một lời cảm ơn vì đã gánh vác mọi mệt mỏi để đưa bạn đi qua ngày hôm nay.",
    "Một góc nhỏ bình yên ở đây luôn mở cửa đón chào bạn quay về, không điều kiện, không phán xét.",
    "Những lo lắng có thể trôi vào hư vô theo từng hơi thở ra thật chậm, thật nhẹ.",
    "Bạn không cần phải hoàn hảo để được yêu thương. Những mảnh vỡ cũng có nét đẹp wabi-sabi của riêng nó.",
    "Khi bạn ngừng đòi hỏi cuộc đời phải dễ dàng hơn, bạn sẽ thấy mình mạnh mẽ hơn rất nhiều.",
    "Đi tìm ý nghĩa từ những điều nhỏ bé nhất: một nụ cười ấm áp, một tách trà thơm, một hơi thở nhẹ.",
    "Bạn là người quan sát những cảm xúc trôi qua, chứ không phải chính những cảm xúc đó. Sự vững chãi nằm ở đó.",
    "Những kỳ vọng của xã hội có thể rơi rụng bên ngoài cánh cửa. Ở đây, bạn chỉ cần là chính mình.",
    "Sự tĩnh lặng nội tâm là pháo đài vững chắc nhất giúp bạn đi qua mọi giông bão cuộc đời.",
    "Cảm xúc khó chịu không phải là lỗi của bạn. Nó chỉ là một vị khách ghé thăm rồi sẽ lại rời đi.",
    "Nhìn lại chặng đường đã qua để thấy bạn đã dũng cảm vượt qua bao nhiêu điều tưởng chừng không thể.",
    "Cho phép bản thân được sai, được làm lại, và được bắt đầu lại từ bất kỳ thời điểm nào.",
    "Hơi ấm từ bếp lửa thấu cảm này luôn sẵn sàng ôm lấy bạn mỗi khi bạn cảm thấy thế giới quá lạnh lùng.",
    "Tương lai là bức tranh chưa vẽ, đừng dùng lo âu của hiện tại để tô màu u ám lên nó.",
    "Chậm lại một nhịp để cảm nhận mặt đất dưới chân vững chãi nâng đỡ bạn từng bước đi.",
    "Bạn đang làm tốt hơn những gì bạn nghĩ. Tin tưởng vào tiến trình tự chữa lành của bản thân là chìa khóa.",
    "Khi bạn tự thương lấy mình, cả thế giới xung quanh bỗng nhiên cũng trở nên dịu dàng hơn.",
    "Để lại sau lưng những gì không thể thay đổi và tập trung năng lượng vào giây phút hiện tại này.",
    "Những chia sẻ vô danh quanh bếp lửa là lời nhắc nhở rằng chúng ta luôn đồng hành cùng nhau trong nỗi đau.",
    "Trút bỏ gánh nặng phải làm hài lòng tất cả mọi người. Người đầu tiên bạn cần trân trọng là chính mình.",
    "Để tâm hồn mình rỗng lặng như một căn phòng sạch sẽ, sẵn sàng đón nhận những điều lành mạnh mới.",
    "Sự bình yên đích thực không nằm ở bên ngoài, nó đã có sẵn trong bạn, chỉ chờ bạn nhận ra và tin vào.",
    "Chúc bạn có một giấc ngủ bình yên đêm nay, để ngày mai lại bắt đầu với một tâm thế nhẹ nhàng, nội sinh."
  ];

  // Danh sách các câu hỏi tự thấu hiểu sâu sắc (Reflection Prompts) phân loại theo Trạng thái tâm lý
  static const Map<String, List<String>> reflectionPrompts = {
    "burnout": [
      "Đâu là ranh giới giữa việc kiên trì cố gắng và việc gồng gánh quá sức chịu đựng của bản thân?",
      "Cơ thể bạn lúc này đang phát đi tín hiệu mệt mỏi ở vùng nào, và nó cần gì nhất từ bạn?",
      "Nếu được phép dừng lại toàn bộ công việc trong một ngày mà không thấy có lỗi, bạn sẽ chăm sóc mình thế nào?",
      "Bạn là ai khi năng suất làm việc của bạn tạm thời trở về số không?",
      "Việc từ chối bớt một kỳ vọng của người khác hôm nay mang lại cảm giác gì cho tâm trí bạn?",
      "Một hành động nhỏ nhất giúp cơ thể bạn được thả lỏng ngay lúc này là gì?",
      "Bạn có đang vô tình tự trách mình vì đã cảm thấy mệt mỏi hay kiệt sức không?",
      "Năng lượng tinh thần của bạn lúc này giống như một ngọn nến sắp tắt hay một bếp lửa chỉ còn tro ấm?",
      "Nếu xem cơn mệt mỏi này là một thông điệp từ cơ thể, nó đang khuyên bạn nên buông bỏ điều gì?",
      "Điều gì trong cuộc sống đang vắt kiệt năng lượng của bạn nhiều nhất, và bạn có thể lùi lại một bước khỏi nó không?"
    ],
    "overthinking": [
      "Nếu tách biệt suy nghĩ của bạn ra khỏi thực tại khách quan, điều gì thực sự đang diễn ra trước mắt?",
      "Kịch bản tồi tệ nhất mà tâm trí đang vẽ ra có thực sự là một mối đe dọa thực tế lúc này không?",
      "Điều gì sẽ xảy ra nếu bạn cho phép câu hỏi đang trăn trở tạm thời không cần tìm kiếm câu trả lời ngay?",
      "Tâm trí bạn lúc này giống như một nút thắt dây thừng hay một dòng sông đang cuộn sóng?",
      "Bạn có đang cố gắng kiểm soát một kết quả mà vốn dĩ nằm ngoài khả năng của mình không?",
      "Nếu lùi lại một bước để quan sát suy nghĩ của mình như người xem kịch, bạn thấy điều gì đang diễn ra trong đầu?",
      "Việc phân tích quá nhiều đang giúp bạn giải quyết vấn đề hay chỉ đang kéo dài cảm giác lo âu?",
      "Một sự thật giản đơn nhất trong hiện tại mà bạn có thể chạm vào lúc này là gì?",
      "Nỗi lo lắng này bắt nguồn từ việc nuối tiếc quá khứ hay sợ hãi tương lai?",
      "Bạn có thể chấp nhận sự mơ hồ của ngày mai như một phần tự nhiên của cuộc sống không?"
    ],
    "lonely": [
      "Nỗi cô đơn đang cố gắng báo hiệu cho bạn về nhu cầu kết nối nào chưa được đáp ứng?",
      "Hôm nay, làm thế nào để bạn tự trở thành một người bạn đồng hành ấm áp, kiên nhẫn nhất của chính mình?",
      "Có ai đó trong quá khứ hay hiện tại từng khiến bạn cảm thấy được thấu hiểu sâu sắc mà không cần giải thích nhiều?",
      "Bạn đang cảm thấy cô độc giữa đám đông hay cô đơn khi ở một mình, và sự khác biệt đó là gì?",
      "Nếu nỗi cô đơn là một người bạn ghé thăm, bạn muốn cùng người bạn đó ngồi im lặng làm gì lúc này?",
      "Bạn có đang đóng một vai diễn không thuộc về mình chỉ để nhận được sự công nhận từ bên ngoài?",
      "Một chia sẻ thầm lặng, chân thật nào từ lòng bạn đang mong mỏi được lắng nghe nhất?",
      "Sự cô đơn này là rào cản ngăn bạn kết nối với thế giới hay là khoảng trống để bạn quay về với chính mình?",
      "Làm thế nào để bạn tự trao cho mình một cái ôm thấu cảm lúc này mà không cần đợi từ người khác?",
      "Khi ở một mình, điều gì về bản thân khiến bạn cảm thấy thoải mái và tự do nhất?"
    ],
    "empty": [
      "Khoảng trống rỗng trong lòng bạn hôm nay đang mở ra không gian cho những khả năng mới nào?",
      "Nếu sự trống rỗng không phải là một vấn đề cần giải quyết, bạn sẽ chung sống với nó ra sao?",
      "Điều gì rất nhỏ bé xung quanh có thể mang lại cho bạn cảm giác hiện diện vật lý lúc này?",
      "Cảm giác vô định có đang mang lại cho bạn một sự tự do để chọn bất kỳ ngã rẽ nào không?",
      "Bạn đang tìm kiếm điều gì để lấp đầy khoảng trống đó, và nó có thực sự đem lại bình an lâu dài?",
      "Bạn là ai khi không có các mục tiêu thúc đẩy hay các kỳ vọng đè nặng trên vai?",
      "Cho phép bản thân được tồn tại một cách lặng lẽ mà không cần dán nhãn hay định nghĩa mang lại cảm giác gì?",
      "Giống như một chiếc tách rỗng chờ nước mới, lòng trống trải của bạn lúc này đang chờ đợi điều gì lành mạnh?",
      "Một ngày trôi qua mà không đạt được thành tựu nào có làm giảm đi giá trị tự thân vô điều kiện của bạn không?",
      "Sự trống rỗng này là một vực thẳm đáng sợ hay là một căn phòng sạch sẽ đang đón gió mát?"
    ],
    "peaceful": [
      "Khoảnh khắc bình an nhỏ bé nhất bạn cảm nhận được ngày hôm nay trông như thế nào?",
      "Khi hơi thở đi vào và đi ra chậm rãi lúc này, bạn nhận thấy cơ thể mình đang cảm thấy thế nào?",
      "Một vẻ đẹp giản dị nào trong thiên nhiên hoặc không gian sống xung quanh đang hiển hiện trước mắt bạn?",
      "Sự bình yên bên trong bạn lúc này giống như một mặt hồ phẳng lặng hay một làn gió nhẹ buổi sớm?",
      "Điều gì trong ngày hôm nay đã khiến bạn cảm thấy biết ơn sự tồn tại của chính mình?",
      "Khi không còn bận tâm đến phán xét của người khác, bạn muốn dành sự quan tâm của mình cho điều gì?",
      "Làm thế nào để bạn nuôi dưỡng cảm giác thư thái này lâu hơn trong các hoạt động tiếp theo?",
      "Mối quan hệ giữa bạn và chính mình lúc này đang ở trạng thái hòa hợp và dịu dàng như thế nào?",
      "Chấp nhận mọi điều vô thường của cuộc sống mang lại cho bạn sự tự do như thế nào trong hiện tại?",
      "Sự bình yên thực sự có phải là khi mọi xáo động bên ngoài dừng lại, hay là khi bạn bình thản đón nhận chúng?"
    ]
  };

  // -----------------------------------------------------------------------
  // Mẫu câu ý định (Intention Templates) — gợi ý theo cảm xúc (CBT Scaffolding)
  // Giúp người dùng vượt qua "Blank Page Anxiety" ở bước viết intention.
  // -----------------------------------------------------------------------
  static const Map<String, List<String>> intentionTemplates = {
    'burnout': [
      'Hôm nay tôi cho phép mình nghỉ ngơi sau khi hoàn thành ',
      'Hôm nay tôi sẽ nói không với ',
      'Hôm nay tôi chỉ cần làm một điều nhỏ là ',
    ],
    'overthinking': [
      'Hôm nay tôi sẽ chỉ tập trung vào 1 việc là ',
      'Hôm nay tôi sẽ buông bỏ lo lắng về ',
      'Hôm nay tôi chọn hành động thay vì phân tích: ',
    ],
    'lonely': [
      'Hôm nay tôi sẽ kết nối lại bằng cách ',
      'Hôm nay tôi muốn tự tặng mình khoảnh khắc ',
      'Hôm nay tôi sẽ trân trọng bản thân bằng cách ',
    ],
    'empty': [
      'Hôm nay tôi muốn thử một điều nhỏ mới là ',
      'Hôm nay tôi sẽ chú ý đến vẻ đẹp nhỏ bé xung quanh, ví dụ như ',
      'Hôm nay tôi chỉ cần tồn tại bình yên và ',
    ],
    'peaceful': [
      'Hôm nay tôi muốn lan tỏa điều tốt bằng cách ',
      'Hôm nay tôi sẽ trân trọng khoảnh khắc ',
      'Hôm nay tôi muốn nuôi dưỡng sự bình yên bằng cách ',
    ],
    'neutral': [
      'Hôm nay tôi muốn tập trung vào ',
      'Hôm nay tôi sẽ hoàn thành ',
      'Hôm nay tôi muốn dành thời gian cho ',
    ],
  };

  // -----------------------------------------------------------------------
  // Các hành động (Micro-Offerings) được ưu tiên theo trạng thái cảm xúc
  // Dựa trên Behavioral Activation: năng lượng thấp → hành động thể chất tối thiểu,
  // năng lượng ổn định → hành động kết nối xã hội & tâm hồn.
  // -----------------------------------------------------------------------
  static const Map<String, List<String>> offeringsByEmotion = {
    'burnout':      ['water', 'breathe', 'stretch'],
    'overthinking': ['breathe', 'nature_look', 'tidy_desk'],
    'lonely':       ['gratitude_msg', 'empathy_hug', 'confess_burn'],
    'empty':        ['water', 'breathe', 'nature_look'],
    'peaceful':     ['gratitude_msg', 'nature_look', 'empathy_hug'],
    'neutral':      ['breathe', 'tidy_desk', 'stretch'],
  };

  // -----------------------------------------------------------------------
  // 5 Mạch Endogenism — Bản đồ hành trình nội tâm
  // -----------------------------------------------------------------------
  static const List<Map<String, dynamic>> endogenCircuits = [
    {
      'id': 1,
      'name': 'Gọi Tên',
      'icon': '🏷️',
      'desc': 'Nhận diện những cạm bẫy tâm lý đang giữ bạn lại',
      'color': 0xff789ec6, // inkBlue
    },
    {
      'id': 2,
      'name': 'Xây Nền Tảng',
      'icon': '🏛️',
      'desc': 'Giá trị vô điều kiện — nền móng không thể lung lay',
      'color': 0xff9cbbaa, // sageGreen
    },
    {
      'id': 3,
      'name': 'Hành Động Nhỏ',
      'icon': '🌱',
      'desc': 'Nghi lễ nhỏ nuôi dưỡng tâm hồn mỗi ngày',
      'color': 0xffe5bf45, // softGold
    },
    {
      'id': 4,
      'name': 'Nhận Ra Giá Trị',
      'icon': '🔭',
      'desc': 'Nhìn thấy điều thật sự quan trọng với bạn',
      'color': 0xffd99b9b, // mistRed
    },
    {
      'id': 5,
      'name': 'Thánh Đường Thể Tục',
      'icon': '🕯️',
      'desc': 'Không gian sống nội sinh bền vững, trọn vẹn',
      'color': 0xffb8c4bc, // sageLight
    },
  ];

  // -----------------------------------------------------------------------
  // Bộ 3 Câu Hỏi Nội Sinh Hàng Ngày (Triday Questions)
  // Dựa trên 3 câu hỏi cốt lõi của Endogenism (index.md)
  // -----------------------------------------------------------------------
  static const Map<String, String> tridayQuestions = {
    'morning': 'Hôm nay bạn hành động từ nỗi sợ thiếu hụt, hay từ nền tảng vững chắc bên trong?',
    'afternoon': 'Thứ gì đang thật sự nuôi dưỡng bạn — không phải kích thích bạn?',
    'evening': 'Bạn là ai khi không có ai nhìn?',
  };

  // -----------------------------------------------------------------------
  // 3 Chủ Đề Buông Đa Giác Quan (Release Ritual Themes)
  // Dựa trên kỹ thuật Cognitive Defusion trong ACT
  // -----------------------------------------------------------------------
  static const List<Map<String, dynamic>> releaseRitualThemes = [
    {
      'id': 'fire',
      'name': 'Thiêu hóa',
      'icon': '🔥',
      'desc': 'Dòng chữ hóa thành tàn lửa bay lên bầu trời đêm',
      'accentColor': 0xffE07A5F,
    },
    {
      'id': 'wave',
      'name': 'Sóng biển',
      'icon': '🌊',
      'desc': 'Sóng nhẹ nhàng liếm trôi dòng chữ trên bãi cát',
      'accentColor': 0xff6a8caf,
    },
    {
      'id': 'leaf',
      'name': 'Lá rơi',
      'icon': '🍂',
      'desc': 'Chiếc lá thu mang theo nỗi lo trôi theo dòng suối',
      'accentColor': 0xffC68B3A,
    },
  ];

  // -----------------------------------------------------------------------
  // Thẻ Bài Tri Thức Nội Sinh (Wisdom Flashcards)
  // Mỗi thẻ: quote, câu hỏi nhanh, mạch tương ứng, cảm xúc phù hợp
  // Trích từ 150+ bài viết endo-book
  // -----------------------------------------------------------------------
  static const List<Map<String, dynamic>> wisdomFlashcards = [
    // Mạch 1 — Gọi Tên: Nhận diện cạm bẫy
    {
      'quote': 'Bạn là ai khi không có ai nhìn?',
      'question': 'Lúc này bạn có đang đóng một vai diễn không thực sự thuộc về mình?',
      'circuit': 1,
      'source': 'Câu hỏi cốt lõi Endogenism',
      'emotions': ['lonely', 'empty', 'neutral'],
    },
    {
      'quote': 'Cố gắng không phải lời nguyền — nhưng cố gắng để chứng minh giá trị thì có.',
      'question': 'Bạn đang cố gắng vì bạn muốn tạo ra điều gì đó, hay vì sợ bị coi là không đủ tốt?',
      'circuit': 1,
      'source': 'Bài 01 — Cố gắng thành lời nguyền',
      'emotions': ['burnout', 'overthinking'],
    },
    {
      'quote': 'Không phải bạn thất bại. Bạn chỉ đang chơi một trò chơi được thiết kế để không ai thắng được.',
      'question': 'Tiêu chí "thành công" bạn đang dùng là của bạn, hay của ai đó khác áp đặt?',
      'circuit': 1,
      'source': 'Bài 04 — Định nghĩa lại sự thất bại',
      'emotions': ['burnout', 'empty', 'overthinking'],
    },
    {
      'quote': 'Nỗi sợ bị bỏ lại phía sau là dấu hiệu bạn đang chạy trong cuộc đua không phải của mình.',
      'question': 'Ai đang ngồi đặt ra đích đến của cuộc đua bạn đang chạy?',
      'circuit': 1,
      'source': 'Bài 06 — Nỗi sợ bị bỏ lại phía sau',
      'emotions': ['overthinking', 'lonely'],
    },
    {
      'quote': 'Cô đơn giữa đám đông là vì bạn đang cố đóng một vai diễn không thuộc về mình.',
      'question': 'Khi ở một mình, bạn cảm thấy nhẹ nhõm hay cô đơn hơn?',
      'circuit': 1,
      'source': 'Bài 08 — Cô đơn giữa thế giới kết nối',
      'emotions': ['lonely', 'empty'],
    },
    {
      'quote': 'Có tất cả mà vẫn trong rỗng — đó không phải vô ơn. Đó là tín hiệu rằng bạn đang tìm nhầm nơi.',
      'question': 'Thứ bạn đang tìm kiếm — nó có đang ở nơi bạn đang tìm không?',
      'circuit': 1,
      'source': 'Bài 09 — Có tất cả mà vẫn trong rỗng',
      'emotions': ['empty', 'burnout'],
    },
    {
      'quote': 'Toxic positivity không chữa lành — nó chỉ ép bạn diễn vai người ổn khi bạn chưa ổn.',
      'question': 'Bạn có đang ép mình "phải tích cực" trong khi thực ra đang cần được lắng nghe?',
      'circuit': 1,
      'source': 'Bài 10 — Toxic positivity không còn tác dụng',
      'emotions': ['burnout', 'lonely'],
    },
    {
      'quote': 'Hội chứng kẻ giả mạo thì thầm: "Rồi họ sẽ biết mình chỉ là một kẻ giả dối."',
      'question': 'Thành tích của bạn có thực sự không đủ, hay bạn chỉ chưa quen tin vào khả năng của mình?',
      'circuit': 1,
      'source': 'Bài 11 — Hội chứng kẻ giả mạo',
      'emotions': ['overthinking', 'burnout'],
    },
    {
      'quote': 'Khi không làm gì mà cảm thấy tội lỗi, đó là dấu hiệu bạn đã gắn giá trị bản thân vào năng suất.',
      'question': 'Giá trị của bạn có giảm đi khi bạn nghỉ ngơi không?',
      'circuit': 1,
      'source': 'Bài 05 — Tại sao không làm gì cảm thấy tội lỗi',
      'emotions': ['burnout', 'empty'],
    },
    {
      'quote': 'Áp lực từ mạng xã hội không đến từ người khác — nó đến từ thuật toán được thiết kế để bạn luôn cảm thấy thiếu.',
      'question': 'Sau 10 phút lướt mạng xã hội, bạn thường cảm thấy thế nào về bản thân?',
      'circuit': 1,
      'source': 'Bài 03 — Áp lực đồng lứa & mạng xã hội',
      'emotions': ['overthinking', 'empty', 'lonely'],
    },
    // Mạch 2 — Xây Nền Tảng
    {
      'quote': 'Thứ bạn đang tìm kiếm không nằm ở phía trước bạn. Nó đã có trong bạn — đang chờ được tin vào.',
      'question': 'Khi bạn không cần chứng minh gì với ai, bạn cảm thấy thế nào về chính mình?',
      'circuit': 2,
      'source': 'Endogenism — Tiên đề cốt lõi',
      'emotions': ['empty', 'peaceful', 'neutral'],
    },
    {
      'quote': 'Giá trị của bạn không tăng khi bạn thành công và không giảm khi bạn thất bại.',
      'question': 'Nếu kết quả hôm nay không thay đổi giá trị của bạn, bạn có hành động khác đi không?',
      'circuit': 2,
      'source': 'Endogenism — Trụ cột 1: Giá trị vô điều kiện',
      'emotions': ['burnout', 'overthinking', 'peaceful'],
    },
    {
      'quote': 'Cảm giác khó chịu không phải vấn đề cần giải quyết — nó là dữ liệu cần được đọc.',
      'question': 'Cảm xúc khó chịu nhất của bạn lúc này đang cố nói với bạn điều gì?',
      'circuit': 2,
      'source': 'Endogenism — Trụ cột 2: Cảm xúc là thông tin',
      'emotions': ['burnout', 'lonely', 'overthinking'],
    },
    {
      'quote': 'Hành động từ nỗi sợ thiếu hụt thì kiệt sức. Hành động từ nền tảng vững chắc thì nuôi dưỡng.',
      'question': 'Hành động quan trọng nhất bạn sẽ làm hôm nay — nó đến từ đâu?',
      'circuit': 2,
      'source': 'Endogenism — Hai loại giá trị',
      'emotions': ['burnout', 'neutral', 'peaceful'],
    },
    {
      'quote': 'Bạn không phải kiếm lấy quyền được tồn tại.',
      'question': 'Nếu không cần chứng minh mình xứng đáng, bạn sẽ dành năng lượng đó làm gì?',
      'circuit': 2,
      'source': 'Endogenism — Trụ cột 1',
      'emotions': ['burnout', 'empty', 'peaceful'],
    },
    {
      'quote': 'Pháo đài tâm lý không phải là nơi tránh né thế giới. Nó là nơi bạn trú lại trong chính mình.',
      'question': 'Bạn đang đứng vững từ bên trong, hay đang phụ thuộc vào sự ổn định bên ngoài?',
      'circuit': 2,
      'source': 'Bài 50 — Pháo đài tâm lý',
      'emotions': ['peaceful', 'overthinking', 'burnout'],
    },
    {
      'quote': 'Bạn không phải là cảm xúc của bạn. Bạn là người đang quan sát cảm xúc đó trôi qua.',
      'question': 'Thay vì "Tôi lo lắng", thử nghĩ "Tôi đang nhận thấy cảm giác lo lắng" — cảm giác thế nào?',
      'circuit': 2,
      'source': 'Bài 43 — Bạn không phải là cảm xúc',
      'emotions': ['overthinking', 'burnout', 'lonely'],
    },
    {
      'quote': 'Ý nghĩa không được tìm thấy — nó được xây từ những lựa chọn nhỏ mỗi ngày.',
      'question': 'Một lựa chọn nhỏ nào hôm nay phản ánh đúng nhất con người bạn muốn trở thành?',
      'circuit': 2,
      'source': 'Endogenism — Trụ cột 3: Ý nghĩa được xây từ dưới lên',
      'emotions': ['empty', 'peaceful', 'neutral'],
    },
    // Mạch 3 — Hành Động Nhỏ
    {
      'quote': 'Một nghi lễ nhỏ không thay đổi thế giới. Nhưng nó thay đổi cách bạn bước vào thế giới đó.',
      'question': 'Một hành động nhỏ nào bạn có thể làm ngay bây giờ để chăm sóc bản thân?',
      'circuit': 3,
      'source': 'Bài 57 — Nghi lễ nhỏ neo giữ tâm hồn',
      'emotions': ['burnout', 'neutral', 'peaceful'],
    },
    {
      'quote': 'Viết nhật ký không phải để trở nên tốt hơn. Là để gặp lại chính mình mỗi ngày.',
      'question': 'Nếu viết một câu thật lòng về hôm nay, câu đó sẽ là gì?',
      'circuit': 3,
      'source': 'Bài 51 — Viết nhật ký',
      'emotions': ['lonely', 'empty', 'peaceful'],
    },
    {
      'quote': 'Chú tâm trọn vẹn không cần ngồi thiền. Nó có thể bắt đầu từ việc uống một ly nước thật chậm.',
      'question': 'Một việc nhỏ bạn thường làm vội vội hôm nay — nếu làm chậm lại thì sao?',
      'circuit': 3,
      'source': 'Bài 33 — Chánh niệm không cần ngồi thiền',
      'emotions': ['burnout', 'overthinking', 'peaceful'],
    },
    {
      'quote': 'Nghi lễ của sự tĩnh lặng giữa lòng thành phố — một tách cà phê không điện thoại là đủ.',
      'question': 'Khi nào lần cuối bạn làm một việc gì đó mà không đồng thời cầm điện thoại?',
      'circuit': 3,
      'source': 'Bài 39 — Sự tĩnh lặng giữa lòng thành phố',
      'emotions': ['burnout', 'overthinking'],
    },
    {
      'quote': 'Sống chậm lại không phải là làm ít đi. Là làm từng việc với sự hiện diện trọn vẹn hơn.',
      'question': 'Nếu hôm nay bạn chỉ làm một việc thật sự chú tâm — bạn sẽ chọn việc gì?',
      'circuit': 3,
      'source': 'Bài 59 — Sống chậm lại',
      'emotions': ['burnout', 'peaceful', 'neutral'],
    },
    // Mạch 4 — Nhận Ra Giá Trị
    {
      'quote': 'Định luật bảo toàn năng lượng tinh thần: Bạn không thể cho những gì bạn không có.',
      'question': 'Bạn đang dùng năng lượng tinh thần của mình vào đâu nhiều nhất?',
      'circuit': 4,
      'source': 'Bài 48 — Định luật bảo toàn năng lượng tinh thần',
      'emotions': ['burnout', 'overthinking'],
    },
    {
      'quote': 'Biết đủ là đủ — không phải buông xuôi, mà là nhận ra thứ gì thực sự quan trọng với bạn.',
      'question': 'Nếu bạn "đủ" rồi — ngay lúc này — bạn sẽ cảm thấy tự do theo cách nào?',
      'circuit': 4,
      'source': 'Bài 52 — Biết đủ là đủ',
      'emotions': ['burnout', 'empty', 'peaceful'],
    },
    {
      'quote': 'Đừng so sánh chương 1 của mình với chương 20 của người khác.',
      'question': 'Bạn đang ở chương mấy trong câu chuyện riêng của mình?',
      'circuit': 4,
      'source': 'Bài 45 — Ngừng so sánh chương 1 với chương 20',
      'emotions': ['burnout', 'lonely', 'overthinking'],
    },
    {
      'quote': 'Tìm kiếm ý nghĩa trong những điều tầm thường là kỹ năng cao nhất của người sống nội sinh.',
      'question': 'Một điều rất nhỏ bé hôm nay đã mang lại cho bạn khoảnh khắc dù chỉ thoáng qua của sự bình yên?',
      'circuit': 4,
      'source': 'Bài 58 — Tìm kiếm ý nghĩa trong tầm thường',
      'emotions': ['empty', 'peaceful', 'neutral'],
    },
    {
      'quote': 'Sở thích cũ không còn làm bạn mỉm cười — đó không phải lười biếng, đó là tín hiệu bạn cần nuôi dưỡng lại.',
      'question': 'Có điều gì bạn từng yêu thích mà bạn đã bỏ lại không? Tại sao?',
      'circuit': 4,
      'source': 'Bài 25 — Sở thích cũ không còn làm bạn mỉm cười',
      'emotions': ['empty', 'lonely'],
    },
    // Mạch 5 — Thánh Đường Thể Tục
    {
      'quote': 'Tâm thế người lữ hành: Không chiếm hữu, không phán xét, chỉ trân trọng.',
      'question': 'Nếu nhìn ngày hôm nay với đôi mắt của một người lữ hành đang ghé thăm, bạn sẽ thấy gì?',
      'circuit': 5,
      'source': 'Bài 60 — Tâm thế người lữ hành',
      'emotions': ['peaceful', 'empty', 'neutral'],
    },
    {
      'quote': 'Memento Mori — nhớ rằng bạn sẽ chết. Không để sợ hãi, mà để sống trọn vẹn hơn.',
      'question': 'Nếu hôm nay là ngày cuối trong cuộc đời, bạn có muốn làm gì khác đi không?',
      'circuit': 5,
      'source': 'Bài 35 — Memento Mori',
      'emotions': ['empty', 'peaceful'],
    },
    {
      'quote': 'Amor Fati — yêu thương số phận, không phải chấp nhận thụ động, mà là biến cả những điều khó chịu thành chất liệu sống.',
      'question': 'Một khó khăn bạn đang trải qua — nếu xem nó là thầy, nó đang dạy bạn điều gì?',
      'circuit': 5,
      'source': 'Bài 36 — Amor Fati',
      'emotions': ['burnout', 'overthinking', 'peaceful'],
    },
    {
      'quote': 'Tự do nội tâm không phải khi không còn ràng buộc — mà là khi những ràng buộc không còn xác định bạn.',
      'question': 'Điều gì bên ngoài đang giữ quyền năng định nghĩa giá trị của bạn nhiều nhất?',
      'circuit': 5,
      'source': 'Bài 49 — Tự do nội tâm',
      'emotions': ['burnout', 'overthinking', 'peaceful'],
    },
    {
      'quote': 'Giới hạn của bạn không phải dấu hiệu yếu đuối. Nhận ra giới hạn là bước đầu của sự khôn ngoan.',
      'question': 'Một điều bạn cần nói không hôm nay để bảo vệ năng lượng tinh thần của mình?',
      'circuit': 5,
      'source': 'Bài 38 — Tại sao nói không',
      'emotions': ['burnout', 'neutral'],
    },
    {
      'quote': 'Tha thứ cho chính mình không phải bào chữa — là giải phóng bản thân khỏi án tù tự tạo.',
      'question': 'Có điều gì bạn đang còn tự trách mình mà thực ra đã đến lúc buông bỏ chưa?',
      'circuit': 5,
      'source': 'Bài 54 — Tha thứ cho chính mình',
      'emotions': ['burnout', 'lonely', 'empty'],
    },
  ];

  // -----------------------------------------------------------------------
  // Nghi Lễ Nhỏ Nội Sinh — Micro-Rituals (Mạch 3)
  // Mỗi nghi lễ: tiêu đề, hướng dẫn chi tiết, thời gian, mạch tương ứng, cảm xúc
  // -----------------------------------------------------------------------
  static const List<Map<String, dynamic>> endogenMicroRituals = [
    {
      'id': 'tea_mindful',
      'title': 'Pha trà định tâm',
      'instruction': 'Pha một tách trà. Không cầm điện thoại. Cảm nhận hơi nóng tỏa ra từ tách trà, mùi thơm, và tiếng nước rót. Uống từng ngụm thật chậm.',
      'duration': '5 phút',
      'circuit': 3,
      'emotions': ['burnout', 'overthinking'],
    },
    {
      'id': 'slow_water',
      'title': 'Ly nước trong lặng',
      'instruction': 'Rót một ly nước. Uống thật chậm rãi trong im lặng hoàn toàn. Cảm nhận từng ngụm nước mát chạm vào cổ họng. Không vừa uống vừa làm việc khác.',
      'duration': '2 phút',
      'circuit': 3,
      'emotions': ['burnout', 'neutral'],
    },
    {
      'id': 'window_gaze',
      'title': 'Ngắm nhìn bầu trời',
      'instruction': 'Nhìn ra cửa sổ và quan sát bầu trời trong 2 phút. Không phán xét, không nghĩ về việc cần làm. Chỉ đơn giản là nhìn và cảm nhận.',
      'duration': '2 phút',
      'circuit': 3,
      'emotions': ['overthinking', 'empty'],
    },
    {
      'id': 'gratitude_moment',
      'title': 'Một điều biết ơn',
      'instruction': 'Đặt tay lên ngực. Nghĩ về một điều rất nhỏ bé hôm nay mà bạn biết ơn — có thể chỉ là ánh nắng buổi sáng hay một cuộc trò chuyện ngắn. Cảm nhận sự biết ơn đó trong 1 phút.',
      'duration': '3 phút',
      'circuit': 3,
      'emotions': ['empty', 'peaceful', 'neutral'],
    },
    {
      'id': 'stretch_release',
      'title': 'Vươn người buông thả',
      'instruction': 'Đứng dậy. Vươn người lên cao hết mức. Giữ 5 giây. Thả lỏng hoàn toàn. Lắc nhẹ cánh tay. Cảm nhận cơ thể trở về trạng thái tự nhiên.',
      'duration': '3 phút',
      'circuit': 3,
      'emotions': ['burnout', 'overthinking'],
    },
    {
      'id': 'breath_anchor',
      'title': 'Neo giữ hơi thở',
      'instruction': 'Hít vào trong 4 giây, giữ 2 giây, thở ra trong 6 giây. Làm 5 lần. Đây là kỹ thuật kích hoạt hệ thần kinh đối giao cảm — cơ chế thư giãn tự nhiên của cơ thể.',
      'duration': '3 phút',
      'circuit': 3,
      'emotions': ['overthinking', 'burnout', 'lonely'],
    },
    {
      'id': 'one_line_journal',
      'title': 'Một dòng nhật ký thật lòng',
      'instruction': 'Viết đúng một câu — câu thật lòng nhất về khoảnh khắc hiện tại của bạn. Không cần hay, không cần chỉnh sửa. Chỉ cần thật.',
      'duration': '2 phút',
      'circuit': 3,
      'emotions': ['lonely', 'empty', 'peaceful'],
    },
    {
      'id': 'silence_room',
      'title': 'Một phút tĩnh lặng',
      'instruction': 'Đặt điện thoại xuống. Nhắm mắt. Không làm gì trong 1 phút. Cứ để suy nghĩ trôi qua như những đám mây. Bạn chỉ cần ngồi đây và thở.',
      'duration': '1 phút',
      'circuit': 3,
      'emotions': ['burnout', 'overthinking', 'neutral'],
    },
  ];

  // -----------------------------------------------------------------------
  // Thiền Dẫn Nhập Nội Sinh (Guided Endogen Meditations)
  // Thay thế zenReadings trong SilenceView
  // -----------------------------------------------------------------------
  static const List<Map<String, dynamic>> endogenMeditations = [
    // Loại 1: Thiền ngắn 5 phút — Nhận ra giá trị vô điều kiện
    {
      'id': 'value_meditation',
      'title': 'Nhận ra giá trị vô điều kiện',
      'duration_minutes': 5,
      'intro': 'Bài thiền 5 phút giúp bạn chạm vào giá trị sẵn có trong mình — không phụ thuộc vào bất kỳ thành tích hay sự công nhận nào.',
      'steps': [
        {
          'phase': 'Đặt nền',
          'content': 'Hãy để cơ thể chìm xuống, thoải mái. Không cần cố gắng làm bất cứ điều gì. Chỉ cần ở đây. Hít một hơi thật sâu — và nhận ra rằng: hơi thở này là bằng chứng bạn đang sống, và điều đó đã là đủ rồi.',
        },
        {
          'phase': 'Nhận thức',
          'content': 'Bạn có giá trị vô điều kiện — không phải vì bạn làm việc tốt, không phải vì ai đó nói vậy, mà vì bạn đang tồn tại. Hãy để câu đó thấm vào từng hơi thở: *"Tôi đủ rồi, ngay lúc này."*',
        },
        {
          'phase': 'Buông thả',
          'content': 'Hãy nghĩ đến một kỳ vọng đang đặt lên vai bạn. Hít vào. Và khi thở ra, tưởng tượng bạn nhẹ nhàng đặt kỳ vọng đó xuống — không phủ nhận, chỉ đơn giản là không mang theo nó lúc này.',
        },
      ],
    },
    // Loại 2: Thiền trung 7 phút — Trở thành người quan sát cảm xúc
    {
      'id': 'observer_meditation',
      'title': 'Trở thành người quan sát',
      'duration_minutes': 7,
      'intro': 'Bài thiền 7 phút giúp bạn tách mình khỏi những cảm xúc đang cuốn bạn đi, trở thành người quan sát bình thản.',
      'steps': [
        {
          'phase': 'Nhận diện',
          'content': 'Hãy chú ý đến cảm xúc đang hiện diện lúc này — không cần gọi tên nó là tốt hay xấu. Chỉ cần nhận ra: *"Tôi đang cảm thấy điều gì đó."* Bạn không phải là cảm xúc đó. Bạn là người đang quan sát nó.',
        },
        {
          'phase': 'Tách rời',
          'content': 'Hãy tưởng tượng cảm xúc của bạn như những đám mây trôi qua bầu trời. Bạn là bầu trời — luôn ở đó, rộng lớn, không bị cuốn theo đám mây nào. Những đám mây có thể dày hay mỏng, nhưng bầu trời không thay đổi.',
        },
        {
          'phase': 'Đọc thông điệp',
          'content': 'Bây giờ hãy hỏi cảm xúc đó một cách dịu dàng: *"Bạn đang cố nói với tôi điều gì?"* Đừng cố trả lời bằng lý trí. Chỉ nghe. Có thể chưa có câu trả lời — và điều đó hoàn toàn ổn.',
        },
      ],
    },
    // Loại 3: Thiền sâu 10 phút — Trả tự do cho những kỳ vọng
    {
      'id': 'freedom_meditation',
      'title': 'Trả tự do cho kỳ vọng',
      'duration_minutes': 10,
      'intro': 'Bài thiền 10 phút giúp bạn nhận ra và nhẹ nhàng đặt xuống những kỳ vọng — của xã hội, gia đình, và của chính mình — để thở tự do hơn.',
      'steps': [
        {
          'phase': 'Khám phá',
          'content': 'Có bao nhiêu "phải" đang ngồi trên vai bạn lúc này? *Phải thành công, phải không phàn nàn, phải làm người khác hài lòng...* Hãy để chúng lần lượt hiện ra — không phán xét, chỉ nhận biết.',
        },
        {
          'phase': 'Phân loại',
          'content': 'Trong những "phải" đó — cái nào thực sự là của bạn? Cái nào là của người khác gán vào? Không cần tranh luận với chúng. Chỉ cần nhận ra khoảng cách giữa *tiếng nói của bạn* và *tiếng nói của kỳ vọng bên ngoài*.',
        },
        {
          'phase': 'Buông thả',
          'content': 'Hãy chọn một kỳ vọng không thực sự thuộc về bạn. Hít vào thật sâu. Khi thở ra, tưởng tượng bạn đang trả nó về cho người đã trao cho bạn — nhẹ nhàng, không giận dỗi. *"Tôi trả tự do cho anh/chị, và tôi trả tự do cho chính mình."*',
        },
        {
          'phase': 'Neo giữ',
          'content': 'Bây giờ đặt tay lên ngực. Cảm nhận nhịp tim. Đây là nhịp của bạn — không ai có thể thiết lập nhịp này cho bạn. Hãy ở lại với nhịp tim của riêng mình thêm vài hơi thở, rồi từ từ trở về với không gian hiện tại.',
        },
      ],
    },
    // Loại 4: Thiền ngắn buổi tối 5 phút — Nghi lễ kết thúc ngày
    {
      'id': 'day_closing_meditation',
      'title': 'Khép lại ngày bình yên',
      'duration_minutes': 5,
      'intro': 'Bài thiền 5 phút cho buổi tối — nhẹ nhàng khép lại một ngày mà không mang theo gánh nặng vào giấc ngủ.',
      'steps': [
        {
          'phase': 'Nhìn lại',
          'content': 'Ngày hôm nay đã qua. Không cần điểm số, không cần đánh giá. Chỉ đơn giản là: *bạn đã sống ngày hôm nay.* Điều đó đã đủ để ghi nhận.',
        },
        {
          'phase': 'Tha thứ',
          'content': 'Có điều gì trong ngày hôm nay bạn cảm thấy chưa hài lòng? Hãy nhìn nó một cách dịu dàng — như nhìn một người bạn đã cố gắng hết sức mình. Và nói: *"Hôm nay bạn đã làm tốt nhất bạn có thể. Đó là đủ rồi."*',
        },
        {
          'phase': 'Thả neo',
          'content': 'Mọi lo lắng về ngày mai, hãy để chúng nằm yên đó đến sáng mai. Bây giờ, hơi thở của bạn là điều duy nhất cần chú ý. Thở vào sự bình yên — thở ra mọi gánh nặng của ngày.',
        },
      ],
    },
  ];
}
