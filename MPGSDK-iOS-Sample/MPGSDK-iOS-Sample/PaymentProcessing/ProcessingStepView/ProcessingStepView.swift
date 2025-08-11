/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

struct ProcessingStepViewModel {
    enum State {
        case loading
        case completed
        case failed
    }
    
    var state: State = .loading
    var sequence: Int
    var stepName: String
    
    init(sequence: Int, stepName: String) {
        self.sequence = sequence
        self.stepName = stepName
    }
}

class ProcessingStepView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet private var stepName: UILabel!
    @IBOutlet private var statusImage: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var model: ProcessingStepViewModel!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init( with model: ProcessingStepViewModel ) {
        super.init(frame: .zero)
        self.commonInit()
        self.load(model: model)
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("ProcessingStepView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    
    func load(model: ProcessingStepViewModel) {
        self.model = model
        stepName.text = "\(model.sequence). \(model.stepName)"
        updateState(state: model.state)
    }
    
    func updateState(state:ProcessingStepViewModel.State) {
        model.state = state
        switch state {
        case .loading:
            statusImage.isHidden = true
            activityIndicator.startAnimating()
        case .completed:
            statusImage.image = UIImage(systemName: "checkmark.circle.fill")
            statusImage.tintColor = .systemGreen
            statusImage.isHidden = false
            activityIndicator.stopAnimating()
        case .failed:
            statusImage.image = UIImage(systemName: "multiply.circle.fill")
            statusImage.tintColor = .systemRed
            statusImage.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}
