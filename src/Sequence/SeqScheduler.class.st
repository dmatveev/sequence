Class {
	#name : #SeqScheduler,
	#superclass : #Object,
	#instVars : [
		'sequence',
		'input'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqScheduler >> completedFrames [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqScheduler >> input [
	^ input
]

{ #category : #accessors }
SeqScheduler >> input: aSeqFrameSource [ 
	input := aSeqFrameSource
]

{ #category : #accessing }
SeqScheduler >> runFor: aDuration [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqScheduler >> sequence [
	^ sequence
]

{ #category : #accessing }
SeqScheduler >> sequence: anObject [
	sequence := anObject
]
