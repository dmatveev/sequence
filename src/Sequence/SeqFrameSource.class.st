Class {
	#name : #SeqFrameSource,
	#superclass : #Object,
	#instVars : [
		'stream',
		'sequence',
		'seqId'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqFrameSource class >> on: aSeqDataStream [ 
	^self on: aSeqDataStream for: nil.
]

{ #category : #'instance creation' }
SeqFrameSource class >> on: aSeqDataStream for: aSequence [
	^self new
		stream: aSeqDataStream;
		sequence: aSequence;
		yourself
]

{ #category : #'instance creation' }
SeqFrameSource class >> using: aDataStreamOrBlock [
	^self using: aDataStreamOrBlock for: nil.
]

{ #category : #'instance creation' }
SeqFrameSource class >> using: aDataStreamOrBlock for: aSequence [
	| stream |
	stream := aDataStreamOrBlock isBlock
		ifTrue: [ SeqDataStream block: aDataStreamOrBlock ]
		ifFalse: [ aDataStreamOrBlock ].
	^self on: stream for: aSequence
]

{ #category : #stream }
SeqFrameSource >> initialize [
	super initialize.
	seqId := 0.
]

{ #category : #streams }
SeqFrameSource >> next [
	| frame |
	frame := SeqFrame new
		id: seqId;
		timestamp: 0 seconds;
		data: stream next;
		sequence: sequence.
	seqId := seqId + 1.
	^frame
]

{ #category : #stream }
SeqFrameSource >> sequence: aSequence [
	sequence := aSequence.
]

{ #category : #stream }
SeqFrameSource >> stream: aSeqDataStream [ 
	stream := aSeqDataStream
]
