import AdWhaleSDK
import UIKit

/// 샘플: AdWhale iOS SDK는 고정 레이아웃이 없으므로, 앱이 `AdWhaleNativeAdView`를 상속해
/// 필수 에셋 뷰를 구현합니다. `AppDelegate`에서 `factoryId` `app_custom`으로 팩토리를 등록합니다.
final class ExampleCustomNativeAdView: AdWhaleNativeAdView {
  private let titleLbl = UILabel()
  private let bodyLbl = UILabel()
  private let ctaBtn = UIButton(type: .system)
  private let profileNameLbl = UILabel()
  private let profileIcon = UIImageView()
  private let whaleMediaView = AdWhaleMediaView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    buildLayout()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    buildLayout()
  }

  private func buildLayout() {
    backgroundColor = .secondarySystemBackground
    titleLbl.font = .boldSystemFont(ofSize: 16)
    titleLbl.numberOfLines = 2
    bodyLbl.font = .systemFont(ofSize: 14)
    bodyLbl.numberOfLines = 3
    bodyLbl.textColor = .secondaryLabel
    profileNameLbl.font = .systemFont(ofSize: 12)
    profileIcon.contentMode = .scaleAspectFill
    profileIcon.clipsToBounds = true
    profileIcon.layer.cornerRadius = 20
    ctaBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
    whaleMediaView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      whaleMediaView.heightAnchor.constraint(equalToConstant: 180),
    ])

    let profileRow = UIStackView(arrangedSubviews: [profileIcon, profileNameLbl])
    profileRow.axis = .horizontal
    profileRow.spacing = 8
    profileRow.alignment = .center
    profileIcon.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      profileIcon.widthAnchor.constraint(equalToConstant: 40),
      profileIcon.heightAnchor.constraint(equalToConstant: 40),
    ])

    let stack = UIStackView(arrangedSubviews: [
      titleLbl,
      bodyLbl,
      whaleMediaView,
      profileRow,
      ctaBtn,
    ])
    stack.axis = .vertical
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
    ])
  }

  override func adTitleLabel() -> UILabel { titleLbl }
  override func adBodyLabel() -> UILabel { bodyLbl }
  override func adCallToActionButton() -> UIButton { ctaBtn }
  override func adProfileNameLabel() -> UILabel { profileNameLbl }
  override func adProfileIconView() -> UIImageView { profileIcon }
  override func adMediaView() -> AdWhaleMediaView { whaleMediaView }
}
