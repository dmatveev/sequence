Class {
	#name : #SeqExecOptionsTest,
	#superclass : #TestCase,
	#instVars : [
		'opts'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqExecOptionsTest >> setUp [
	super setUp.
	opts := SeqExecOptions new
]

{ #category : #tests }
SeqExecOptionsTest >> testDropFrames [
	opts dropFrames.
	self assert: opts hasFrameDropAllowed equals: true.
]

{ #category : #tests }
SeqExecOptionsTest >> testHasFrameDropAllowed [
	"No frame drops by default"
	self assert: opts hasFrameDropAllowed equals: false.
]

{ #category : #tests }
SeqExecOptionsTest >> testInputStream [
	"Even if the stream isn't configured, we should have one by default"
	self assert: opts inputStream isNotNil
]

{ #category : #tests }
SeqExecOptionsTest >> testInputStream2 [
	"If we configure one, we should use one"
	| s |
	s := (SeqFrameSource on: (SeqDataStream block: [])).
	opts inputStream: s.
	self assert: opts inputStream identicalTo: s.
]

{ #category : #tests }
SeqExecOptionsTest >> testInputStream3 [
	"Check it is not recreated every time (who knows)"
	| s1 s2 |
	s1 := opts inputStream.
	s2 := opts inputStream.
	self assert: s1 identicalTo: s2.
]

{ #category : #tests }
SeqExecOptionsTest >> testPriority [
	"Priority must have something by default.
	Let it be at least zero"
	self assert: opts priority equals: 0.

	"But changes are accepted`"
	opts priority: 8.
	self assert: opts priority equals: 8.
]

{ #category : #tests }
SeqExecOptionsTest >> testSequence [
	"This is absolute ugliness, but this is how it is used in the code"
	| s |
	s := Sequence startingWith: ('a' asSeqBlock latency: 1 ms).
	opts sequence: s.
	self assert: opts inputStream sequence identicalTo: s.
	
]
