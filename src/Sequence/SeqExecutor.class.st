Class {
	#name : #SeqExecutor,
	#superclass : #Object,
	#category : #Sequence
}

{ #category : #accessing }
SeqExecutor >> runFor: aDuration [
	self subclassResponsibility 
]
