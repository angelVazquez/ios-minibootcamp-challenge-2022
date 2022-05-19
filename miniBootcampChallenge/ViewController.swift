//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    var images:[UIImage] = [UIImage]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.refresh()
    }
    @objc func refresh(){
        refreshControl.beginRefreshing()
        images = [UIImage]()
        self.collectionView.reloadData()
        downloadImages { complete in
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
        }
    }
}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.

extension ViewController{
    //Solution for challenge 1
    func downloadSingleImage(url:URL, onCell cell:ImageCell){
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                cell.display(UIImage(data: data!)!)
            }
        }
    }
    //Solution for challenge 2
    func downloadImages(completionHandler:@escaping(_ complete:Bool) ->Void) {
        
        DispatchQueue.global().async {
            for url in self.urls {
                let data = try? Data(contentsOf: url)
                self.images.append(UIImage(data: data!)!)
            }
            DispatchQueue.main.async {
                completionHandler(true)
            }
        }
    }
}


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        cell.display(self.images[indexPath.row])
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
          let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
