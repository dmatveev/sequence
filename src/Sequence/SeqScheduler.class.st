Class {
	#name : #SeqScheduler,
	#superclass : #Object,
	#category : #Sequence
}

{ #category : #accessing }
SeqScheduler >> runFor: aDuration [
	self subclassResponsibility 
]
