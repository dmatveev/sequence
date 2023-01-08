Class {
	#name : #SeqFrameTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqFrameTest >> testDropped [
	| f |
	f := SeqFrame new.
	
	"By default a SeqFrame isn't considered dropped"
	self assert: f dropped equals: false.
]

{ #category : #tests }
SeqFrameTest >> testMarkDropped [
	| f |
	f := SeqFrame new.
	f markDropped.
	
	self assert: f dropped equals: true.
]
