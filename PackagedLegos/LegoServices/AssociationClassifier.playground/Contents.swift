// Classification Through Address Association


import Foundation
import CreateML

let csvFile = Bundle.main.url(forResource: "topContributorsWithLogs", withExtension: "csv")!
let dataTable = try MLDataTable(contentsOf: csvFile)
print(dataTable)


let regressorColumns = ["ins","outs","inAmount","outAmount","timeBetween","topics","sybil"]
let regressorTable = dataTable[regressorColumns]
print(regressorTable)

let classifierColumns = ["address","ins","outs","inAmount","outAmount","timeBetween","topics","isContract","sybil"]
let classifierTable = dataTable[classifierColumns]
print(classifierTable)

let (regressorEvaluationTable, regressorTrainingTable) = regressorTable.randomSplit(by: 0.20, seed: 5)
let (classifierEvaluationTable, classifierTrainingTable) = classifierTable.randomSplit(by: 0.20, seed: 5)

let regressor = try MLLinearRegressor(trainingData: regressorTrainingTable,
                                      targetColumn: "sybil")

/// The largest distances between predictions and the expected values
let worstTrainingError = regressor.trainingMetrics.maximumError
let worstValidationError = regressor.validationMetrics.maximumError

/// Evaluate the regressor
let regressorEvalutation = regressor.evaluation(on: regressorEvaluationTable)

/// The largest distance between predictions and the expected values
let worstEvaluationError = regressorEvalutation.maximumError

let classifier = try MLClassifier(trainingData: classifierTrainingTable,
                                  targetColumn: "sybil")

/// Classifier training accuracy as a percentage
let trainingError = classifier.trainingMetrics.classificationError
let trainingAccuracy = (1.0 - trainingError) * 100

/// Classifier validation accuracy as a percentage
let validationError = classifier.validationMetrics.classificationError
let validationAccuracy = (1.0 - validationError) * 100

/// Evaluate the classifier
let classifierEvaluation = classifier.evaluation(on: classifierEvaluationTable)

/// Classifier evaluation accuracy as a percentage
let evaluationError = classifierEvaluation.classificationError
let evaluationAccuracy = (1.0 - evaluationError) * 100


/// Get Desktop folder’s path.
let homePath = FileManager.default.homeDirectoryForCurrentUser
let desktopPath = homePath.appendingPathComponent("Desktop")


let regressorMetadata = MLModelMetadata(author: "Mitchell Tucker",
                                        shortDescription: "For shadows sybil behivor based on transactions.",
                                        version: "1.0")
/// Save the trained regressor model to the Desktop.
try regressor.write(to: desktopPath.appendingPathComponent("AssociationRegressor.mlmodel"),
                    metadata: regressorMetadata)

/*:
 The playground similarly saves the purpose classifier to the user’s desktop.
 */
let classifierMetadata = MLModelMetadata(author: "Mitchell Tucker",
                                         shortDescription: "Predicts sybil behavior based on transactions.",
                                         version: "1.0")

/// Save the trained classifier model to the Desktop.
try classifier.write(to: desktopPath.appendingPathComponent("AssociationClassifier.mlmodel"),
                     metadata: classifierMetadata)

