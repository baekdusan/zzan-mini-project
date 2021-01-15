import UIKit
import AVFoundation
import GoogleMobileAds

// 차례대로 짠 소리, 몇 잔인지, 배열 위치가 어딘지, 배경 이미지 변수
var soundEffect: AVAudioPlayer?
var cupnumber = 0
var countingNum = 0
var image: UIImage!

// 순서에 맞는 배열(다른 이미지나 소리를 변경할 때에 위 아래에 순서 맞춰서 요소 집어넣어주면 됌)
var imageArray: [String] = ["glass", "soju", "cocktail", "bottle"]
var soundArray: [String] = ["zzan", "zzan2", "zzan", "zzan2"]

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    // 광고 뷰, 배경 컨트롤해주는 메소드
    var bannerView: GADBannerView!
    let imagePickerController = UIImagePickerController()
 
    //전체 뷰, 인스타 캡쳐용 뷰
    @IBOutlet var allView: UIView!
    @IBOutlet weak var captureView: UIView!

    //몇잔 나타내는 라벨
    @IBOutlet weak var drinknum: UILabel!
 
    // 잔 좌우 간격, 맨 처음 클릭 애니메이션 위아래 간격, 몇잔 y위치 간격
    @IBOutlet weak var quoteCenterX: NSLayoutConstraint!
    @IBOutlet weak var tipY: NSLayoutConstraint!
    @IBOutlet weak var cupnumY: NSLayoutConstraint!
  
    // 인스타 공유, 리셋, 잔 바꾸기, 짠, 정보, 배경 버튼
    @IBOutlet weak var instaUI: UIButton!
    @IBOutlet weak var resetUI: UIButton!
    @IBOutlet weak var changeUI: UIButton!
    @IBOutlet weak var zzan: UIButton!
    @IBOutlet weak var refUI: UIButton!
    @IBOutlet weak var backUI: UIButton!
 
    // 맨처음 클릭 애니메이션, 잔 좌우 이미지, 배경, 지금까지, 몇, 잔 이미지 뷰
    @IBOutlet weak var clickUI: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var Picture: UIImageView!
    @IBOutlet weak var sofar: UILabel!
    @IBOutlet weak var cupNumber: UILabel!
    @IBOutlet weak var cup: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 광고 관련 메소드
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-9457112413608323/6965792049"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // 배경화면 메소드
        imagePickerController.delegate = self
        
        // 각 UI 그림자 넣는 함수(간단하게 못하나..)
        makeShadow(type: refUI)
        makeShadow(type: backUI)
        makeShadow(type: zzan)
        makeShadow(type: resetUI)
        makeShadow(type: changeUI)
        makeShadow(type: instaUI)
        makeLabelShadow(type: sofar)
        makeLabelShadow(type: cupNumber)
        makeLabelShadow(type: cup)
        
        // 디폴트 값 불러내기(마신 잔 수, 배경)
        cupnumber = UserDefaults.standard.integer(forKey: "number")
        drinknum.text = "\(cupnumber)"
        
        // 잔 종류 디폴트 값 불러내기
        countingNum = UserDefaults.standard.integer(forKey: "kind")
        let alcoholkind = countingNum % 4
        changeImage(kind: imageArray[alcoholkind])
                
        // 마신 잔이 0잔일 때만 클릭 애니메이션 호출
        if cupnumber != 0 {
            clickUI.alpha = 0
        } else {
        tipAnimation()
        }
        
        // 이미지 경로 불러오기
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        if let dirPath = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("image.png")
            let image = UIImage(contentsOfFile: imageURL.path) ?? UIImage(named: "standard")
            
            Picture.image = image
            Picture.alpha = 0.8
        }
    }

    // 짠 버튼
    @IBAction func playbtn(_ sender: Any) {
        
        // 클릭 애니메이션 제거
        clickUI.alpha = 0
        
        // 제일 기본 기능(잔 소리와 부딪히는 동작 맞추기 위해 시간 설정)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {self.byArraySound()})
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {self.showAnimation()})
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200), execute: {self.count()})
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {self.prepareAnimation()})
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {self.zzanAnimation()})
    }
    
    // 리셋 버튼
    @IBAction func resetbtn(_ sender: Any) {
        cupnumber = 0
        drinknum.text = "\(cupnumber)"
        UserDefaults.standard.set(cupnumber, forKey: "number")
        
        UIView.transition(with: drinknum, duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: {
                            self.drinknum.isHidden = false
                      })
    }
    
    // 잔 바꾸기 버튼
    @IBAction func changebtn(_ sender: Any) {
        leftImage.alpha = 0
        rightImage.alpha = 0
        byArrayImage()
        changeAnimation(type: leftImage)
        changeAnimation(type: rightImage)
    }
    
    // Info 버튼 -> 이미지 저작권
    @IBAction func refbtn(_ sender: Any) {
        let alert = UIAlertController(title: "Info", message: "glass, beer icon designed by\nhttps://www.iconfinder.com/dooder\n\ncocktail, soju icon designed by Dusan Baek\n\n'짠! Cheers! developed by Dusan Baek", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // 인스타 공유 버튼
    @IBAction func sharebtn(_ sender: Any) {
        
        onoff(type: 0)
        
        if let storyShareURL = URL(string: "instagram-stories://share") {
            
            if UIApplication.shared.canOpenURL(storyShareURL) {
                
                let renderer = UIGraphicsImageRenderer(size: captureView.bounds.size)
                let renderImage = renderer.image { _ in captureView.drawHierarchy(in: captureView.bounds, afterScreenUpdates: true) }
                        
                    guard let imageData = renderImage.pngData() else {return}

                    let pasteboardItems : [String:Any] = [
                            "com.instagram.sharedSticker.backgroundImage": imageData,
                            "com.instagram.sharedSticker.backgroundTopColor" : "#ffffff",
                            "com.instagram.sharedSticker.backgroundBottomColor" : "#ffffff" ]
                        
                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : Date().addingTimeInterval(300)]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(storyShareURL, options: [:], completionHandler: nil)
                        
            } else {
                    let alert = UIAlertController(title: "", message: "You need instagram", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
            }
        }
        
        onoff(type: 1)
    }
    
    // 배경화면 바꾸는 버튼(카메라, 앨범, 스탠다드 이미지(흰색))
    @IBAction func picturebtn(_ sender: Any) {
        let alert = UIAlertController(title: "Background Image", message: "Change the mood\nby setting the background!", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera 📷", style: .default, handler: {(action: UIAlertAction!) in self.openCamera()})
        let album = UIAlertAction(title: "Album 🏞", style: .default, handler: {(action: UIAlertAction!) in self.openAlbum()})
        let standard = UIAlertAction(title: "Standard Color", style: .default, handler: {(action: UIAlertAction!) in self.standardImage()})
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(album)
        alert.addAction(standard)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
//함수 모음
    
    // 소리나오게 하는 함수
    func playAudio(type: String) {
        
        let url = Bundle.main.url(forResource: "\(type)", withExtension: "m4a")
     
        if let url = url{
             
            do {
                soundEffect = try AVAudioPlayer(contentsOf: url)
                guard let sound = soundEffect else { return }
                
                sound.prepareToPlay()
                sound.play()
                 
            } catch let error {
                 print(error.localizedDescription)
            }
        }
    }
    
    // 몇 잔인지 숫자 세주는 함수
    func count() {
        
        if cupnumber == 99 {
            cupnumber = 0
        } else {
        cupnumber += 1
        }
        
        UserDefaults.standard.set(cupnumber, forKey: "number")
        drinknum.text = "\(cupnumber)"
        UIView.transition(with: drinknum, duration: 0.4,
                          options: .transitionFlipFromBottom,
                          animations: {self.drinknum.isHidden = false })
    }
    
    // 잔 부딪힐 때 준비 애니메이션
    func prepareAnimation() {
        quoteCenterX.constant = view.bounds.width / 2
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // 잔 부딪힐 때 본 애니메이션
    func showAnimation() {
        quoteCenterX.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .allowUserInteraction, animations: {self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // 짠 버튼 애니메이션
    func zzanAnimation() {
        zzan.isHidden = false
        zzan.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.6, delay: 0.8, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveLinear, animations: {
                self.zzan.alpha = 1.0;
                self.zzan.transform = .identity
        }, completion: nil)
    }
    
    // 잔 종류 그림 바뀌는 애니메이션
    func changeAnimation(type: UIView) {
        type.isHidden = false
        type.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 2, options: .curveLinear, animations: {
                type.alpha = 1.0;
                type.transform = .identity
        }, completion: nil)
    }
    
    // 클릭 애니메이션
    func tipAnimation() {
        clickUI.isHidden = false
        clickUI.transform = CGAffineTransform(translationX: 0, y: -10)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.4, options: [.curveLinear, .repeat, .autoreverse], animations: {
                self.clickUI.transform = .identity
        }, completion: nil)
    }
    
    // 잔 이미지 바꾸기
    func changeImage(kind: String) {
        leftImage.image = UIImage(named:"\(kind)left")
        rightImage.image = UIImage(named:"\(kind)right")
    }
    
    // 잔 배열 요소 넘기기
    func byArrayImage() {
        countingNum += 1
        let currentNum = countingNum % 4
        
        let type = currentNum
        changeImage(kind: imageArray[type])
        if countingNum == 100 {
            countingNum = 0
        }
        UserDefaults.standard.set(countingNum, forKey: "kind")
    }
    
    // 소리 배열 요소 넘기기
    func byArraySound() {
        let type = countingNum % 4
        playAudio(type: "\(soundArray[type])")
    }
    
    // 기본 이미지(흰색)
    func standardImage() {
        if let image = UIImage(named: "standard") {
            Picture.image = image
            let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                let newPath = path.appendingPathComponent("image.png")
            let data = image.pngData()
                do {
                    try data!.write(to: newPath)
                } catch {
                    print(error)
                }
        }
    }
    
    // 버튼 그림자
    func makeShadow(type: UIButton) {
        type.layer.shadowColor = UIColor.white.cgColor
        type.layer.shadowOpacity = 1.0
        type.layer.shadowOffset = CGSize.zero
        type.layer.shadowRadius = 6
    }

    // 라벨 그림자
    func makeLabelShadow(type: UILabel) {
        type.layer.shadowColor = UIColor.white.cgColor
        type.layer.shadowOpacity = 1.0
        type.layer.shadowOffset = CGSize.zero
        type.layer.shadowRadius = 6
    }
    
    // 광고 함수 (광고 위치 바꾸는 방법 고민해보기)
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    // 카메라 호출
    func openCamera() {
        self.imagePickerController.sourceType = .camera
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    // 앨범 호출
    func openAlbum() {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    // 이미지 골라서 배경으로 넘기는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        UserDefaults.standard.set(cupnumber, forKey: "number")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            Picture.image = image
            Picture.alpha = 0.8
            let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                let newPath = path.appendingPathComponent("image.png")
            let data = image.pngData()
                do {
                    try data!.write(to: newPath)
                } catch {
                    print(error)
                }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // 인스타 공유시 잠시 버튼들 opacity값을 0으로 만들어줬다가 1로 만들어주는 녀석
    func onoff(type: Int) {
        instaUI.alpha = CGFloat(type)
        resetUI.alpha = CGFloat(type)
        changeUI.alpha = CGFloat(type)
        refUI.alpha = CGFloat(type)
        backUI.alpha = CGFloat(type)
    }
}
