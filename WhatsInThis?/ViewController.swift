//
//  ViewController.swift
//  WhatsInThis?
//
//  Created by Zach Halvorsen on 6/17/16.
//  Copyright © 2016 Halvorsen Games. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoLibrary: UIButton!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var search: UIButton!
    
    var activityIndicator:UIActivityIndicatorView!
    var ingredients = [Ingredient]();
    let key = "RztZWknXhRXeMPlPJUsXM0QJebrYYAiCkcWsFcAU"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func searchAction(sender: UIButton) {
        let strings = textView.text.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for i in strings {
            let ing = GetIngredient(i)
            if(ing.amount > 0 && ing.measurement != Ingredient.Measure.NOTHING && ing.object != "") {
                ingredients.append(ing);
            }
        }
        for ing in ingredients {
            SearchDataBase(ing.object, offset: 0)
        }
    }
    
    @IBAction func photoLibraryAction(sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func GetIngredient(line: String) -> Ingredient {
        let ing = Ingredient()
        var words = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for word in words {
            if let val: Double? = Double(word) {
                if( val != nil) {
                    ing.amount += val!
                    print("Amount: ", val)
                    words.removeAtIndex(words.startIndex)
                }
                else if( word.containsString("/")) {
                    let operands = word.componentsSeparatedByString("/")
                    let op1 = NSString(string: operands[0]).doubleValue
                    let op2 = NSString(string: operands[1]).doubleValue
                    ing.amount += op1/op2
                    words.removeAtIndex(words.startIndex)
                    print("Amount: ", ing.amount, "op1: ", op1, "op2: ", op2)
                }
                else {
                    print("Done with amount")
                    break
                }
            }
        }
        
        if let temp1 = words.first?.stringByReplacingOccurrencesOfString(".", withString: "") {
            if let temp2: String? = temp1.stringByReplacingOccurrencesOfString("s", withString: "") {
                if(ing.getMeasurementFromString(temp2!)) {
                    words.removeAtIndex(words.startIndex)
                    print("Measurement: ", ing.measurement)
                }
            }
        }
        
        ing.object = words.joinWithSeparator("_");
        print("Object: ", ing.object)
        return ing;
    }
    
    func SearchDataBase(search: String, offset: Int) {
        let url = NSURL(string: "http://api.nal.usda.gov/ndb/search/?format=json&q=" + search + "&sort=r&max=&offset=" + String(offset) + "&api_key=" + key)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {data, response, error -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.HTTP_Response(NSData(data: data!), response: response!)
        }
        
        task.resume()
    }
    
    func GetNutrients(ndbno: String) {
        let url = NSURL(string: "http://api.nal.usda.gov/ndb/reports/?ndbno=" + ndbno + "&type=f&format=json&api_key=" + key)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {data, response, error -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.HTTP_Response(NSData(data: data!), response: response!)
        }
        
        task.resume()
    }
    
    func HTTP_Response(data: NSData, response: NSURLResponse) {
        //dispatch_sync(dispatch_get_main_queue(), { self.textView.text = data });
        
        do {
            var curIng = Ingredient();
            var object = curIng.object;
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let list = json["list"] as? [String: AnyObject] {
                if let q = list["q"] as? String {
                    for ing in ingredients {
                        if ing.object.caseInsensitiveCompare(q) == NSComparisonResult.OrderedSame {
                            curIng = ing;
                            object = curIng.object.stringByReplacingOccurrencesOfString("_", withString: " ")
                        }
                    }
                }
                if let items = list["item"] as? [[String: AnyObject]] {
                    for item in items {
                        if let name = item["name"] as? String {
                            if name.caseInsensitiveCompare(object) == NSComparisonResult.OrderedSame {
                                
                            }
                        }
                    }
                }
            }
            else if let report = json["report"] as? [String: AnyObject] {
                if let food = report["food"] as? [String: AnyObject] {
                    if let nutrients = food["nutrients"] as? [[String: AnyObject]] {
                        for nutrient in nutrients {
                            
                        }
                    }
                }
            }
            
        } catch {
            print("error serializing JSON: \(error)")
        }
    }
    
    @IBAction func cameraAction(sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }
    
    func performImageRecognition(image: UIImage) {
//        var tesseract:G8Tesseract = G8Tesseract(language:"eng");
//        //tesseract.language = "eng";
//        tesseract.delegate = self;
//        tesseract.charWhitelist = "01234567890";
//        tesseract.image = UIImage(named: "image_sample.jpg");
//        tesseract.recognize();
//        
//        NSLog("%@", tesseract.recognizedText);
        let tesseract:G8Tesseract = G8Tesseract(language:"eng");
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        textView.text = tesseract.recognizedText
        textView.editable = true
        removeActivityIndicator()
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }
    
}

