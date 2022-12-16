Class {
	#name : #SeqRoundRobinScheduler,
	#superclass : #SeqScheduler,
	#instVars : [
		'decisions'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqRoundRobinScheduler >> decide: aCollectionOfStreams [
	"Look at the streams ready for execution and select the right one"
	"At the each point, select a stream with a minumum number of decisions assigned"
	
	| earliest |
	
	"TODO: Test would identify it earlier!"
	aCollectionOfStreams size = 1 ifTrue: [ ^self markDecision: aCollectionOfStreams first].
	
	earliest := aCollectionOfStreams first nextTick.
	^self markDecision: (self selectRR: (aCollectionOfStreams select: [ :each | each nextTick = earliest ])). 
]

{ #category : #'as yet unclassified' }
SeqRoundRobinScheduler >> decisions: aStream [
	^decisions at: aStream ifAbsentPut: [ 0 ].
]

{ #category : #'as yet unclassified' }
SeqRoundRobinScheduler >> initialize [
	super initialize.
	decisions := Dictionary new.
]

{ #category : #'as yet unclassified' }
SeqRoundRobinScheduler >> markDecision: aStream [
	decisions at: aStream update: [ :x | x + 1 ] initial: 1.
	^aStream
]

{ #category : #'as yet unclassified' }
SeqRoundRobinScheduler >> selectRR: aCollectionOfStreams [
	"FIXME: Generating the whole sorted collection is likely highly inefficient"
	^ (aCollectionOfStreams
		asSortedCollection: [ :s1 :s2 | (self decisions: s1) < (self decisions: s2) ])
		first

]
