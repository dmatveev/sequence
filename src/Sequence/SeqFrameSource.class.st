Class {
	#name : #SeqFrameSource,
	#superclass : #Object,
	#instVars : [
		'stream',
		'seq'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqFrameSource class >> on: aSeqDataStream [ 
	^self new
		stream: aSeqDataStream;
		yourself
]

{ #category : #stream }
SeqFrameSource >> initialize [
	super initialize.
	seq := 0.
]

{ #category : #streams }
SeqFrameSource >> next [
	| frame |
	frame := SeqFrame new
		id: seq;
		timestamp: 0 seconds;
		data: stream next.
	seq := seq + 1.
	^frame
]

{ #category : #stream }
SeqFrameSource >> stream: aSeqDataStream [ 
	stream := aSeqDataStream
]
