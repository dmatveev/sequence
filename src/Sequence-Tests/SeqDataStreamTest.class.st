Class {
	#name : #SeqDataStreamTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqDataStreamTest >> testBlock [
	"Testing the different ways of specifying a data stream"
	| d |
	d := SeqDataStream block: [ 42 ].
	self assert: d next equals: 42.
	self assert: d next equals: 42.
]

{ #category : #tests }
SeqDataStreamTest >> testBlock1 [
	"Testing the different ways of specifying a data stream"
	| d counter |
	counter := 0.
	d := SeqDataStream block: [ | r |
		r := counter + 42.
		counter := counter + 1.
		r ].
	self assert: d next equals: 42.
	self assert: d next equals: 43.
	self assert: d next equals: 44.
]
