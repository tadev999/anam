class ZenConstants {
  // Phân loại Châm ngôn theo Trạng thái tâm lý (Tâm trạng)
  static const Map<String, List<String>> emotionalAffirmations = {
    "burnout": [
      "Sự tồn tại của bạn đã là một món quà. Không cần chứng minh gì cả.",
      "Bạn không cần phải chạy thật nhanh. Đi chậm lại cũng là một sự tiến bộ.",
      "Thành công lớn nhất của hôm nay chỉ đơn giản là bạn đã chăm sóc tốt cho bản thân.",
      "Hãy dịu dàng với chính mình hôm nay. Bạn đang làm rất tốt.",
      "Nghỉ ngơi cũng là một hình thức chuẩn bị cho hành trình phía trước. Đừng cảm thấy tội lỗi.",
      "Bạn là một con người (human being), không phải một cái máy làm việc (human doing). Hãy lắng nghe hơi thở của mình."
    ],
    "overthinking": [
      "Chúng ta chỉ có thể kiểm soát cánh buồm, không thể kiểm soát hướng gió. Hãy học cách buông bỏ.",
      "Mọi cảm xúc tiêu cực chỉ như mây trôi qua bầu trời tâm trí. Trời rồi sẽ lại xanh.",
      "Quá khứ đã qua, tương lai chưa tới. Sức mạnh của bạn nằm ngay ở giây phút này.",
      "Hôm nay, hãy để mọi thứ diễn ra tự nhiên. Mọi sự sắp đặt đều có lý do của nó.",
      "Suy nghĩ chỉ là những làn sóng trên mặt hồ tâm trí. Hãy để hồ nước phẳng lặng tự nhiên.",
      "Bạn không phải là suy nghĩ của bạn. Bạn là người đang quan sát những suy nghĩ đó trôi qua."
    ],
    "lonely": [
      "Một hành động tử tế nhỏ bé có thể thắp sáng cả một ngày u ám.",
      "Sâu thẳm bên trong bạn luôn có một nguồn sức mạnh tự thân chưa được khai phá.",
      "Bạn không cô đơn, vũ trụ này đang thở cùng nhịp với bạn.",
      "Bão tố ngoài kia dữ dội đến đâu, sâu thẳm trong lòng vẫn luôn có một nơi tĩnh lặng.",
      "Kết nối chân thành bắt đầu từ việc bạn thấu hiểu và chấp nhận chính sự cô đơn của mình.",
      "Có một bếp lửa ấm áp luôn chờ đón bạn ở đây, trong chốn bình yên này."
    ],
    "empty": [
      "Trống rỗng không có nghĩa là vô giá trị. Đó là khoảng trống để bạn gieo trồng những hạt mầm mới.",
      "Hãy để tâm trí rỗng lặng như một căn phòng đón nhận làn gió mát buổi sớm mai.",
      "Khi không biết đi đâu, đó là lúc bạn được tự do lựa chọn mọi con đường.",
      "Chấp nhận sự trống trải của thực tại chính là bước đầu tiên để chạm vào sự tự do tối hậu.",
      "Giống như tre rỗng ruột mới tạo nên tiếng sáo du dương, tâm hồn tĩnh lặng mới nghe được âm thanh cuộc sống."
    ],
    "peaceful": [
      "Bình yên không phải là một điểm đến, mà là cách bạn bước đi trong cuộc đời.",
      "Nhìn sâu vào thiên nhiên, bạn sẽ thấu hiểu mọi thứ một cách sâu sắc hơn.",
      "Mỉm cười với hiện tại, trân trọng những điều giản dị quanh mình hôm nay.",
      "Mọi khoảnh khắc trôi qua đều là độc nhất vô nhị. Hãy thưởng thức nó trọn vẹn.",
      "Khi tâm ta bình yên, thế giới xung quanh cũng tự khắc trở nên hiền hòa."
    ]
  };

  // Danh sách phẳng để duy trì khả năng tương thích ngược
  static final List<String> dailyAffirmations = emotionalAffirmations.values.expand((list) => list).toList();

  // Danh sách các hành động nhỏ (Micro-offerings) chữa lành phong phú
  static const List<Map<String, dynamic>> microOfferings = [
    {
      "id": "water",
      "title": "Uống một ly nước đầy",
      "description": "Hãy uống thật chậm rãi, cảm nhận sự tươi mát thấm vào từng tế bào cơ thể.",
      "duration": "1 phút",
      "points": 5,
      "category": "body",
      "icon": "water_drop",
    },
    {
      "id": "breathe",
      "title": "5 hơi thở chánh niệm sâu",
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
      "title": "Viết và đốt bỏ nỗi lo",
      "description": "Viết ra 1 điều làm bạn mệt mỏi nhất hôm nay vào 'Góc buông bỏ' và nhấn nút hóa tro nó.",
      "duration": "3 phút",
      "points": 10,
      "category": "mind",
      "icon": "local_fire_department",
    },
    {
      "id": "empathy_hug",
      "title": "Gửi một cái ôm vô danh",
      "description": "Vào khu vực 'Bộ lạc thấu cảm', đọc tâm sự của một người lạ và nhấn nút 'Sưởi ấm' họ.",
      "duration": "2 phút",
      "points": 15,
      "category": "soul",
      "icon": "favorite",
    },
  ];
}
