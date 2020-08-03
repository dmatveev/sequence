Class {
	#name : #SeqDurationTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqDurationTest >> testEquality [
	self assert: 50 fps equals: 20 ms
]

{ #category : #tests }
SeqDurationTest >> testFPS [
	self assert: 20 fps duration equals: 50 ms duration  
]

{ #category : #tests }
SeqDurationTest >> testMs [
	self assert: 33 ms latency equals: 33.
	self assert: 0.2 ms latency equals: 0.2.
]
