//
//  ViewController.swift
//  ExButton
//
//  Created by Jake.K on 2022/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  private let myView: MyView = {
    let view = MyView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(self.myView)
    self.view.addSubview(self.label)
    
    NSLayoutConstraint.activate([
      self.myView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.myView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.myView.widthAnchor.constraint(equalToConstant: 120),
      self.myView.heightAnchor.constraint(equalToConstant: 120),
    ])
    
    NSLayoutConstraint.activate([
      self.label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 56),
      self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
    ])
    
    self.myView.playButtonTapObservable
      .map { "pressed play !" }
      .bind(to: self.label.rx.text)
      .disposed(by: self.myView.disposeBag)
    
    self.myView.stopButtonTapObservable
      .map { "pressed stop !" }
      .bind(to: self.label.rx.text)
      .disposed(by: self.myView.disposeBag)
  }
}

final class MyView: UIView {
  private let button: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "play"), for: .normal)
    button.setImage(UIImage(named: "play-pressed"), for: .highlighted)
    button.setImage(UIImage(named: "stop"), for: .selected)
    button.setImage(UIImage(named: "stop-pressed"), for: [.selected, .highlighted])
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  private var onPlayButtonPressed: Observable<Bool> {
    self.button.rx.isHighlighted
      .filter { $0 == true }
      .withLatestFrom(self.button.rx.isSelected)
      .map { !$0 }
  }

  var playButtonTapObservable: Observable<Void> {
    self.onPlayButtonPressed
      .filter { $0 == false }
      .map { _ in return Void() }
      .asObservable()
  }
  var stopButtonTapObservable: Observable<Void> {
    self.onPlayButtonPressed
      .filter { $0 == true }
      .map { _ in return Void() }
      .asObservable()
  }
  
  private(set) var disposeBag = DisposeBag()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(self.button)
    NSLayoutConstraint.activate([
      self.button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      self.button.widthAnchor.constraint(equalToConstant: 120),
      self.button.heightAnchor.constraint(equalToConstant: 120),
    ])
    
    self.onPlayButtonPressed
      .bind(to: self.button.rx.isSelected)
      .disposed(by: self.disposeBag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension Reactive where Base: UIControl {
  public var isHighlighted: Observable<Bool> {
    self.base.rx.methodInvoked(#selector(setter: self.base.isHighlighted))
      .compactMap { $0.first as? Bool }
      .startWith(self.base.isHighlighted)
      .distinctUntilChanged()
      .share()
  }
  public var isSelected: Observable<Bool> {
    self.base.rx.methodInvoked(#selector(setter: self.base.isSelected))
      .compactMap { $0.first as? Bool }
      .startWith(self.base.isSelected)
      .distinctUntilChanged()
      .share()
  }
}
