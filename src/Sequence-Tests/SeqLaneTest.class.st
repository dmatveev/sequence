Class {
	#name : #SeqLaneTest,
	#superclass : #TestCase,
	#instVars : [
		'block',
		'lane',
		'frame'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqLaneTest >> setUp [
	super setUp.
	block := 'Camera' asSeqBlock latency: 20 ms.
	lane := SeqLane new.
	frame := SeqFrame new id: 0; timestamp: 0 ms.
]

{ #category : #tests }
SeqLaneTest >> testLock [
	lane lock: block at: 0 seconds inContextOf: frame.
	self assert: lane isLocked.
]

{ #category : #tests }
SeqLaneTest >> testNewIsLocked [
   "A lane shouldn't be locked by default"
	self deny: lane isLocked.
]

{ #category : #tests }
SeqLaneTest >> testRelease [
   lane lock: block at: 0 seconds inContextOf: 0.
	lane release: block.
	self deny: lane isLocked.
	self assert: lane events size equals: 1.
]
