Class {
	#name : #BaselineOfSequence,
	#superclass : #BaselineOf,
	#category : #BaselineOfSequence
}

{ #category : #baselines }
BaselineOfSequence >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ "Dependencies"
				spec baseline: 'Roassal2' with: [ spec repository: 'github:///ObjectProfile/Roassal2' ].
				spec package: 'Sequence'.
				spec package: 'Sequence-Tests' with: [ spec requires: #('Sequence') ]]
]
