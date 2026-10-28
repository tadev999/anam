# Thiết kế Webapp AI-DLC: quản lý spec và phối hợp PO – DEV – AI

## 1. Mục tiêu

Xây dựng SaaS mỏng để theo dõi và điều phối quy trình PO–DEV–AI. Coding agent hiện
có chạy trong IDE, tạo spec và hỗ trợ code/test; spec chuẩn được lưu trong Git
spec repo, còn PO duyệt bằng Spec PR. SaaS nhận sự kiện từ Jira, Git và CI/CD để
thông báo, hiển thị tiến độ và đồng bộ trạng thái.

MVP không xây editor spec, kho spec riêng, coding agent mới hay IDE extension.

### Vai trò của từng hệ thống

| Hệ thống | Trách nhiệm / nguồn dữ liệu chuẩn |
|---|---|
| Jira | Backlog, độ ưu tiên, assignee, sprint và trạng thái công việc |
| SaaS webapp | Cấu hình tích hợp, liên kết Jira/Git, trạng thái tổng hợp, notifications và audit metadata; không phải nguồn chuẩn của spec |
| Git spec repo | Nguồn chuẩn của spec, revision, review/approval history và commit SHA/content hash |
| Git code repo | Source code, Code PR và lịch sử code |
| CI/CD | Kết quả build/test/deploy trên đúng commit |
| IDE agent | Đọc baseline, lập kế hoạch kỹ thuật, hỗ trợ code/test/review và báo cáo trace theo AC |

Git spec repo là nguồn chuẩn của spec và lịch sử phê duyệt; Code PR ghim chính xác
spec commit đã được duyệt. SaaS lưu read model/trạng thái cần để phục vụ giao diện,
không giữ một bản spec chuẩn thứ hai. Draft có thể tồn tại trên nhánh PR; sau khi
được duyệt, spec được merge và không sửa trực tiếp, mọi thay đổi tạo commit/revision
mới.

## 2. Nguyên tắc thiết kế

1. AI đề xuất; PO quyết định nghiệp vụ; DEV xác nhận tính khả thi; Tech Lead/QA
   tham gia theo mức rủi ro.
2. Không bắt đầu code theo luồng yêu cầu spec nếu chưa có approval hợp lệ cho đúng
   revision.
3. Approval gắn với danh tính người duyệt, spec revision, content hash và thời điểm.
4. Spec đã duyệt là bất biến. Sửa nội dung tạo revision mới; approval cũ không kế thừa.
5. Tách rõ duyệt spec, hoàn tất kỹ thuật, nghiệm thu sản phẩm và release.
6. Jira, Git và SaaS có quyền sở hữu trường dữ liệu riêng; Git là nguồn chuẩn spec,
   Jira là nguồn chuẩn backlog, SaaS là read model/điều phối.
7. Nếu Git/Jira/CI không đồng bộ được, hiển thị trạng thái lỗi rõ ràng; không báo
   hoàn tất giả.
8. Bắt đầu với một Jira project, một Git provider và một team pilot.

## 3. Luồng nghiệp vụ

```text
Jira story
   ↓
DEV + coding agent tạo spec trong nhánh Git → mở Spec PR
   ↓
Webhook cập nhật SaaS → thông báo PO → PO review/approve Spec PR
   ↓
Spec PR merge: commit SHA là baseline đã duyệt
   ↓
DEV lấy baseline từ Git → AI trong IDE lập plan/code/test/debug
   ↓
DEV review → Code PR → CI test/build → Preview
   ↓
AI hỗ trợ mapping AC/evidence → PO xem preview và nghiệm thu
   ↓
Merge/release → webhook cập nhật SaaS và Jira
```

Trong MVP, PO review ở giao diện Git provider; SaaS chỉ nhận webhook, gửi link/
notification và tổng hợp trạng thái. PO sửa spec bằng review comment/yêu cầu sửa;
DEV hoặc coding agent cập nhật nhánh PR, không sửa nội dung trong SaaS.

### Các trạng thái

| Trạng thái | Ý nghĩa | Sự kiện chuyển trạng thái |
|---|---|---|
| Draft | AI/DEV đang tạo spec trên nhánh PR | Nhánh spec được tạo/cập nhật |
| Spec Review | Spec PR đang chờ PO | Git provider phát sự kiện PR opened/ready for review |
| Changes Requested | PO yêu cầu chỉnh sửa trên PR | Review event yêu cầu thay đổi |
| Approved | PO đã approve đúng head commit | Git provider xác nhận review; commit mới làm approval stale theo policy |
| Published | Spec PR đã merge; commit merge/head được xác định làm baseline | Git provider phát sự kiện merged |
| In Progress | DEV bắt đầu triển khai | Jira transition hoặc Git branch/Code PR event |
| Technical Review | Có Code PR, CI/review đang chạy | Git provider nhận Code PR |
| Acceptance | Có build/preview kiểm tra được | CI đạt trên commit được đề nghị nghiệm thu |
| Done | PO nghiệm thu và Code PR đã merge | Jira acceptance transition và Git merge event |
| Released | Bản phát hành được CI/CD xác nhận | Nhận sự kiện deploy thành công |

Không phải mọi loại ticket đều cần đủ các trạng thái này. Luồng sửa nhỏ không đổi
hành vi có thể bỏ qua spec webapp theo chính sách team.

## 4. Spec và revision

### 4.1 Nội dung spec mặc định

Giữ spec ngắn với năm phần:

1. **Mục tiêu:** vấn đề, người dùng và cách đo thành công.
2. **Phạm vi:** trong phạm vi, ngoài phạm vi, ràng buộc và phụ thuộc.
3. **Acceptance Criteria:** các yêu cầu có ID ổn định và kiểm thử được.
4. **Câu hỏi mở:** giả định chưa xác nhận, người trả lời và hạn trả lời.
5. **Rủi ro:** rủi ro nghiệp vụ/kỹ thuật và biện pháp giảm thiểu.

Thêm phần luồng UX, business rules, dữ liệu, phân quyền, hiệu năng hoặc vận hành
khi story có liên quan hoặc thuộc luồng rủi ro cao.

### 4.2 Dạng lưu trữ và xuất bản

Spec được coding agent tạo thành Markdown trong Git spec repo. SaaS đọc metadata
qua Git API/webhook để hiển thị trạng thái và link; không duy trì nội dung spec như
nguồn chuẩn. Có thể dùng CI để kiểm tra cấu trúc và trường bắt buộc trước khi PR
được gửi PO.

Ví dụ cấu trúc snapshot trong Git spec repo:

```text
specs/APP-123/
  spec.md
  manifest.json
```

`manifest.json` tối thiểu gồm:

```json
{
  "issueId": "jira-instance-id:100123",
  "issueKey": "APP-123",
  "revision": 4,
  "schemaVersion": 1,
  "contentHash": "sha256:...",
  "approvedBy": "user-id",
  "approvedAt": "2026-10-28T10:00:00Z"
}
```

Đây là format đề xuất, cần chốt schema trước khi triển khai. Không coi `issueKey`
đơn lẻ là định danh ổn định vì Jira key có thể đổi. Spec PR ghi nhận PO review;
manifest/CI gắn approval với commit đã duyệt và commit merge trở thành baseline.

### 4.3 Approval

Trong MVP, Git provider là nơi ghi nhận approval chính thức: người duyệt, review
decision, thời gian, PR và commit SHA. SaaS nhận webhook, lưu metadata tối thiểu,
hiển thị kết quả và link về review gốc. Khi PR có commit mới, approval cũ phải bị
dismiss hoặc không còn đáp ứng policy; PO review lại head commit mới nhất.

SaaS không tạo approval thứ hai. Nếu sau này cần duyệt trực tiếp trên SaaS, approval
phải gắn với PR head SHA/hash và backend phát required status check cho Git provider.

## 5. Git spec repo và code repo

Tách spec và code thành hai repo có thể phù hợp khi PO cần quyền truy cập spec mà
không cần quyền đọc/ghi code, hoặc một spec áp dụng cho nhiều client/repo.

### Repo spec

- Lưu các snapshot Markdown/manifest và lịch sử revision.
- Tài khoản tích hợp tạo commit/PR; không giả danh PO.
- Webapp lưu danh tính PO đã sửa/duyệt riêng trong audit log.
- Snapshot đã publish không được sửa tại chỗ; revision mới tạo snapshot mới.

### Repo code

- Chứa source, test, Code PR và cấu hình tích hợp IDE.
- Code PR dẫn Jira issue ID, spec revision, spec repo và commit SHA.
- CI kiểm tra hash snapshot khớp với baseline đã duyệt.

### Quy trình publish và approval cho MVP

1. Coding agent tạo/cập nhật `spec.md` và `manifest.json` trên branch riêng.
2. Tạo Spec PR, liên kết Jira issue, gắn label `spec`, và yêu cầu PO review.
3. Git provider gửi webhook tới SaaS; SaaS cập nhật trạng thái và gửi notification.
4. PO review/approve hoặc request changes trên Git provider. Khi cần sửa, DEV/agent
   cập nhật PR; commit mới khiến review cũ stale theo branch policy.
5. Sau approval, PR được merge. SaaS ghi nhận merge SHA và cập nhật Jira sang Ready.
6. Code PR tham chiếu chính xác merge SHA/hash spec đã duyệt.

Không cần webapp proxy toàn bộ nội dung Git hay có editor spec trong MVP. Nếu PO
không có tài khoản/quyền trên Git provider, đây là yêu cầu có thể khiến cần thêm
UI approval trực tiếp và status check; không nên xây song song hai nơi duyệt.

## 6. IDE agent và cổng bắt đầu phát triển

### 6.1 AI tham gia ở những bước nào?

| Bước | AI trong IDE làm gì? | Kết quả / người xác nhận |
|---|---|---|
| Nhận việc | Đọc baseline đã duyệt, quy tắc repo và task Jira được cấp quyền | Nêu revision/hash đang dùng; DEV xác nhận đúng story |
| Lập kế hoạch | Đọc code liên quan, đề xuất cách làm, module ảnh hưởng, rủi ro và thứ tự task | DEV review/điều chỉnh plan; Tech Lead duyệt khi cần |
| Code | Tạo/chỉnh code theo task và AC; giải thích diff; không tự mở rộng phạm vi | DEV kiểm tra diff, kiến trúc, bảo mật và chịu trách nhiệm |
| Test | Đề xuất test case theo AC; tạo/cập nhật test phù hợp; chạy test được phép và báo kết quả | CI chạy lại trên commit PR; CI là bằng chứng chính thức, không dùng lời AI tự báo thay thế |
| Debug | Phân tích lỗi từ test/log được phép, đề xuất sửa và chạy lại test liên quan | DEV review sửa đổi và kiểm tra không làm lệch baseline |
| Review PR | Tóm tắt diff, liên kết code/test với REQ/AC, chỉ ra phần chưa có coverage hoặc rủi ro | DEV/Code Owners quyết định review và merge; AI không tự approve/merge |
| Preview | Đọc kết quả build/preview; nếu được cấp công cụ, hỗ trợ kiểm tra UI/screenshot theo checklist | CI cung cấp URL/build và trạng thái; PO kiểm tra hành vi thực tế |
| Chuẩn bị nghiệm thu | Tạo checklist AC, tóm tắt thay đổi, test pass/fail, giới hạn đã biết và link preview | PO ghi nhận Đạt/Chưa đạt trong Jira hoặc workflow hiện có; SaaS phản chiếu quyết định |

AI chỉ chạy tool/test nằm trong allowlist của project. Không cấp mặc định quyền
deploy production, sửa dữ liệu thật, thay đổi permission hoặc merge PR.

AI có thể đề xuất mapping từng AC tới test/evidence và trạng thái `covered`,
`tested`, `blocked` hoặc `not-tested`. DEV/QA xác nhận mapping khi cần. Không
tuyên bố AC đạt chỉ vì AI đã tạo test; kết quả pass/fail phải lấy từ CI trên đúng
commit.

### 6.2 Lấy baseline và bắt đầu phát triển

**MVP không cần IDE adapter riêng.** DEV clone/pull spec repo theo quy trình Git
hiện có, checkout commit đã merge và mở cả spec lẫn code repo trong workspace.
Coding agent hiện có đọc `spec.md`, `manifest.json` và quy tắc codebase để lập plan,
code, sinh/chạy test, debug và chuẩn bị PR.

Trước khi code, DEV kiểm tra Spec PR đã merged và ghi spec repo commit SHA/hash vào
Code PR. CI xác minh tham chiếu và hash theo script/check đơn giản. Điều này nhanh
hơn xây API/MCP/extension mới, nhưng là gate ở quy trình/CI: không ngăn DEV chạy
agent cục bộ trước approval. Nếu cần chặn cứng việc lấy baseline, bổ sung adapter
hoặc policy/hook sau pilot.

Adapter/API/MCP có thể bổ sung sau để kiểm tra quyền, lấy baseline tự động, ghi
execution metadata và gửi câu hỏi/tiến độ. Chỉ xây khi có nhu cầu vận hành đã được
pilot chứng minh.

Nếu spec đổi trong lúc execution đang chạy, DEV giữ nguyên baseline hoặc chủ động
chuyển sang revision mới sau khi đánh giá ảnh hưởng. Không tự cập nhật spec giữa
chừng.

## 7. Tích hợp Jira và thông báo

Jira tiếp tục làm nguồn chuẩn cho backlog, priority, assignee và trạng thái ticket.
Webapp liên kết issue bằng Jira instance + immutable issue ID; dùng issue key để
hiển thị.

MVP đồng bộ một chiều các trường cần thiết và cập nhật Jira theo sự kiện đã xác
nhận. Các ví dụ:

- Tạo workspace từ Jira issue hoặc dán issue link.
- Khi spec chuyển sang Spec Review, thông báo PO qua inbox/email/Slack/Teams.
- Khi Spec PR được PO approve và merge, cập nhật Jira sang Ready.
- Khi mở Code PR, cập nhật Jira link PR và In Progress/Technical Review theo workflow.
- Khi CI tạo preview, gửi PO link preview và checklist AC.
- Khi PO nghiệm thu trên Jira/workflow hiện có, phản chiếu kết quả; trạng thái Released chỉ nhận từ CI/CD.

Webhook cần xác thực, chống xử lý sự kiện trùng, retry/backoff, rate-limit handling,
đối soát trạng thái và audit. Tài khoản tích hợp không được làm lộ issue hoặc
attachment mà người dùng hiện tại không có quyền truy cập.

## 8. Trải nghiệm PO và DEV

### PO

- Inbox hiển thị Spec PR/Code PR đang cần review, người phụ trách, thời gian chờ và link mở trực tiếp trên Git provider.
- PO đọc diff, comment, request changes hoặc approve trên Git provider; Git giữ danh tính và lịch sử review.
- SaaS hiển thị approval state, PR head/merge SHA, các revision và link tới nguồn gốc.
- Acceptance view hiển thị preview/build, checklist AC, CI evidence và trạng thái từ Jira; PO mở nguồn phù hợp để ghi nhận quyết định.

### DEV

- Team board cho thấy trạng thái Jira/spec/code, người phụ trách và blocker.
- Workspace hiển thị baseline đã duyệt, thay đổi mới và liên kết tới Git/CI.
- Code PR template/CI check ghi baseline SHA/hash; IDE dùng Git và coding agent hiện có, chưa cần thao tác riêng trong SaaS.
- Spec change trong lúc code có impact summary trước khi chuyển baseline.

## 9. Phân luồng theo rủi ro

| Luồng | Dùng khi | Approval |
|---|---|---|
| Nhanh | Sửa lỗi nhỏ, không đổi hành vi nghiệp vụ, không chạm vùng nhạy cảm | Jira/code review/CI theo chính sách; có thể không cần spec web |
| Chuẩn | Tính năng thông thường | PO duyệt spec ngắn trước khi baseline được cấp cho IDE |
| Kỹ | Dữ liệu, phân quyền, thanh toán, migration, kiến trúc hoặc nhiều team | PO duyệt nghiệp vụ; DEV/Tech Lead duyệt kỹ thuật; QA tham gia theo yêu cầu |

AI có thể gợi ý luồng, DEV xác nhận và PO/Tech Lead có thể nâng luồng. Quy tắc CI
hoặc CODEOWNERS cần chặn merge nếu PR luồng Nhanh chạm vùng yêu cầu kiểm soát cao.

## 10. Bảo mật và vận hành

- SSO và authorization theo project/vai trò; kiểm tra quyền ở API, nội dung AI,
  attachment, tìm kiếm và bản xuất.
- Không đưa secrets hoặc PII không cần thiết vào prompt, log, spec hoặc PR.
- Jira issue, Markdown và source code là dữ liệu không đáng tin; không coi nội dung
  đó là system instruction cho AI.
- Credential Git/Jira chỉ lưu trong backend/secret store; agent chỉ nhận quyền tối thiểu.
- Hành động nguy hiểm, deploy hoặc thay đổi quyền cần người có thẩm quyền xác nhận.
- Audit log không cho người dùng thông thường sửa/xóa; có retention, backup và khôi phục.
- Phân biệt evidence do AI/DEV cung cấp với CI check lấy trực tiếp từ provider.
- Theo dõi lỗi đồng bộ, thời gian chờ PO, chi phí AI và trạng thái queue.

## 11. MVP và tiêu chí hoàn thành

### Phạm vi MVP

1. Một SaaS tenant, một Jira project, một Git provider, một Git spec repo và một code repo.
2. Jira/Git OAuth hoặc Git App install, webhook validation và tenant/project mapping.
3. Dashboard/inbox phản chiếu Jira issue, Spec PR, Code PR, CI, preview và ai đang cần hành động.
4. Notification cho PO khi Spec PR cần review; PO review/approve trực tiếp ở Git provider.
5. Spec Markdown/manifest, PR template và CI lint/hash check; coding agent trong IDE tạo spec/code/test.
6. Jira status update và links từ verified Git/CI events; retry và minimal audit metadata.
7. SaaS hiển thị preview/evidence và trạng thái acceptance từ Jira hoặc workflow hiện có; không xây nút nghiệm thu riêng trong MVP.

### Tiêu chí nghiệm thu MVP

- CI chặn merge Code PR luồng Chuẩn/Kỹ nếu thiếu Spec PR đã merge hoặc baseline SHA/hash không khớp; MVP chưa ngăn DEV chạy agent cục bộ trước approval.
- Sửa spec sau approval tạo revision mới; approval cũ không áp dụng.
- Spec commit/PR liên kết được với revision, PO review identity, thời gian và hash qua Git provider/SaaS event record.
- Code PR cho biết baseline đã dùng; CI không chấp nhận hash không khớp.
- AI có thể đề xuất mapping AC → test/evidence; kết quả pass/fail lấy từ CI của đúng commit.
- AI không thể tự approve spec, tự đánh dấu PO acceptance hoặc tự merge/deploy production.
- Approval/notification/webhook trùng không tạo nhiều bản ghi hoặc transition lặp.
- Lỗi publish/sync hiển thị rõ và có retry; không tuyên bố Published khi Git chưa xác nhận.
- PO nghiệm thu đúng build/commit; merge không tự đồng nghĩa với acceptance hoặc release.
- Người mất quyền Jira/Git không tiếp tục đọc dữ liệu qua bản sao hoặc AI context.

### Lộ trình pilot

1. Chốt Git provider, Jira project, Spec PR template, CODEOWNERS và trạng thái cần đồng bộ.
2. Pilot thủ công một vài story: coding agent tạo spec trong nhánh Git, PO duyệt PR, DEV code theo merged spec SHA.
3. Xây SaaS pilot cho một tenant, có mô hình tenant-aware và test cách ly dữ liệu: OAuth/App install, webhooks, inbox/status, notifications và Jira updates; không làm spec editor hay IDE plugin.
4. Thêm preview/acceptance automation nếu CI hiện tại chưa cung cấp đủ thông tin.
5. Chỉ thêm IDE adapter hoặc approval UI riêng khi pilot cho thấy Git PR không đủ.
6. Mở rộng providers/projects sau khi kiểm chứng cách ly tenant, quyền truy cập và số liệu hiệu quả.

## 12. Câu hỏi cần chốt

1. Git provider là GitHub, GitLab, Bitbucket hay Azure Repos?
2. Xác nhận Git PR là nguồn approval duy nhất cho MVP; mọi approval UI khác để sau pilot.
3. PO có tài khoản và quyền truy cập spec repo không?
4. PO có quyền/tài khoản trên Git provider để review Spec PR không?
5. Một Jira story ánh xạ một spec hay có thể có nhiều spec/code repo?
6. IDE assistant nào cần hỗ trợ đầu tiên; chấp nhận CLI/API/MCP adapter không?
7. Những thay đổi nào cần Tech Lead/QA hoặc bắt buộc luồng Kỹ?
8. Retention cho spec, attachment, execution và audit là bao lâu?

---

## Phụ lục: mẫu spec ngắn

```markdown
# APP-123: <Tên yêu cầu>

## Mục tiêu
<Người dùng gặp vấn đề gì? Kết quả mong muốn và cách đo?>

## Phạm vi
- Trong phạm vi:
- Ngoài phạm vi:
- Ràng buộc/phụ thuộc:

## Acceptance Criteria
- REQ-01 / AC-01: Given ... When ... Then ...
- REQ-02 / AC-02: Given ... When ... Then ...

## Câu hỏi mở và giả định
- [ ] <Câu hỏi> — Người trả lời: <vai trò/người>
- Giả định cần xác nhận:

## Rủi ro
- <Rủi ro> — <Cách giảm thiểu>
```
