Class {
	#name : #SeqEventTest,
	#superclass : #TestCase,
	#instVars : [
		'block',
		'lane',
		'event'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqEventTest >> setUp [
	super setUp.
	block := 'Camera' asSeqBlock latency: 20 ms.
	lane := SeqLane new.
	lane lock: block at: 1 second.
	lane release: block.
	event := lane events first.
]

{ #category : #running }
SeqEventTest >> testBlock [
	self assert: event block identicalTo: block
]

{ #category : #running }
SeqEventTest >> testStartTime [
	self assert: event startTime equals: 1 second
]
