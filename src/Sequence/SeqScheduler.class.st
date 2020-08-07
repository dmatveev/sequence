Class {
	#name : #SeqScheduler,
	#superclass : #Object,
	#instVars : [
		'head',
		'targets',
		'topo'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqScheduler >> completedFrames [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqScheduler >> head [
	^ head
]

{ #category : #accessing }
SeqScheduler >> head: anObject [
	head := anObject
]

{ #category : #accessing }
SeqScheduler >> runFor: aDuration [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqScheduler >> targets [
	^ targets
]

{ #category : #accessing }
SeqScheduler >> targets: anObject [
	targets := anObject
]

{ #category : #accessing }
SeqScheduler >> topo [
	^ topo
]

{ #category : #accessing }
SeqScheduler >> topo: anObject [
	topo := anObject
]
