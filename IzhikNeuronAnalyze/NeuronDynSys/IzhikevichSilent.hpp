#ifndef IZHIKEVICH_SPIKING_DYNSYS
#define IZHIKEVICH_SPIKING_DYNSYS

#include "Headers/DynamicalSystem.hpp"
#include <Grid2D/Headers/Range.hpp>
#include <Grid2D/MexHeaders/MexIO.hpp>

#include <MexMemoryInterfacing/Headers/GenericMexIO.hpp>
#include <cmath>
#include "stdint.h"
#include <functional>

class IzhikevichSilent {

};

template<>
class DynamicalSystem<IzhikevichSilent> {
private:
	GridTransform<float> PrivateTransform;
	PointSet PrivateInitialPointSet;
	DiscreteRange XRange, YRange;

	float a, b, c, d; // Izhikevich neuron parameters
	float timeStep;   // neuron simulation time step.
	SinglePoint ActualStableEquilibriumPoint;
	// Here X is u, and Y is v;
public:
	enum Exceptions {
		INVALID_PARAMETERS
	};
	const PointSet &InitialPointSet;
	const GridTransform<float> &Transform;
	DynamicalSystem()
		: Transform(PrivateTransform),
		  InitialPointSet(PrivateInitialPointSet),
		  XRange(), YRange() {
		PrivateTransform.scaleX = 1;
		PrivateTransform.scaleY = 1;
		PrivateTransform.shiftX = 0;
		PrivateTransform.shiftY = 0;
	}
	DynamicalSystem(const mxArray* ParamArray) : DynamicalSystem() {
		this->frommxArray(ParamArray);
	}

	inline void frommxArray(const mxArray *ParamArray) {
		/*
		 * This function expects the ParamArray to be a MATLAB structure with 
		 * at-least the following fields
		 * 
		 *   a - single - scalar
		 *   b - single - scalar
		 *   c - single - scalar
		 *   d - single - scalar
		 *   
		 *   GridXSpec - single - vector of length 3
		 *   GridYSpec - single - vector of length 3
		 *   
		 *   GridXSpec = [GridXBegin, GridXStep, GridXEnd]
		 *   GridYSpec = [GridYBegin, GridYStep, GridYEnd]
		 *
		 *   onemsbyTstep - uint32_t - scalar
		 *
		 */
		getInputfromStruct<float>(ParamArray, "a", this->a, getInputOps(2, "is_required", "required_size", 1));
		getInputfromStruct<float>(ParamArray, "b", this->b, getInputOps(2, "is_required", "required_size", 1));
		getInputfromStruct<float>(ParamArray, "c", this->c, getInputOps(2, "is_required", "required_size", 1));
		getInputfromStruct<float>(ParamArray, "d", this->d, getInputOps(2, "is_required", "required_size", 1));

		uint32_t onemsbyTstep;
		getInputfromStruct<uint32_t>(ParamArray, "onemsbyTstep", onemsbyTstep, getInputOps(2, "is_required", "required_size", 1));

		MexVector<float> GridXSpec;
		MexVector<float> GridYSpec;

		getInputfromStruct<float>(ParamArray, "GridXSpec", GridXSpec, getInputOps(2, "is_required", "required_size", 3));
		getInputfromStruct<float>(ParamArray, "GridYSpec", GridYSpec, getInputOps(2, "is_required", "required_size", 3));

		float eps = 1E-10; // epsilon used for floating point comparisons
		uint32_t XGridMax, YGridMax;
		XGridMax = uint32_t((GridXSpec[2] - GridXSpec[0])/GridXSpec[1] + 2*eps) + 1;// largest n such that (n-1)*GridXSpec[1] + GridXSpec[0] <= GridXSpec[2]
		YGridMax = uint32_t((GridYSpec[2] - GridYSpec[0])/GridYSpec[1] + 2*eps) + 1;// largest n such that (n-1)*GridYSpec[1] + GridYSpec[0] <= GridYSpec[2]

		this->PrivateTransform.scaleX = GridXSpec[1];
		this->PrivateTransform.scaleY = GridYSpec[1];
		this->PrivateTransform.shiftX = GridXSpec[0];
		this->PrivateTransform.shiftY = GridYSpec[0];

		this->XRange = {0, XGridMax};
		this->YRange = {0, YGridMax};

		this->timeStep = 1.0f / onemsbyTstep;

		// Calculating the Equilibrium Point
		auto getDiscriminant = [&] (float a, float b, float c) -> float { return b*b-4*a*c; };
		auto getQuadSoln = [&] (float a, float b, float c) -> float { return (-b-std::sqrt(getDiscriminant(a,b,c)))/(2*a);};
		
		if(getDiscriminant(0.04f, 5.0f - this->b, 140.0f) >= 0) {
			this->ActualStableEquilibriumPoint.y = getQuadSoln(0.04f, 5.0f - this->b, 140.0f);
			this->ActualStableEquilibriumPoint.x = this->b * this->ActualStableEquilibriumPoint.y;
		}
		else {
			WriteException(
				DynamicalSystem<IzhikevichSilent>::Exceptions::INVALID_PARAMETERS,
			    "There appears to be no equilibrium for the given a,b specified"
			);
		}

		auto GridStableEquilibriumPointf = this->Transform.toGridCoords(this->ActualStableEquilibriumPoint);
		Point GridStableEquilibriumPoint;
		GridStableEquilibriumPoint.x = uint32_t(GridStableEquilibriumPointf.x+0.5f);
		GridStableEquilibriumPoint.y = uint32_t(GridStableEquilibriumPointf.y+0.5f);

		if (this->XRange.contains(GridStableEquilibriumPoint.x) && this->YRange.contains(GridStableEquilibriumPoint.y)) {
			PrivateInitialPointSet.insert(GridStableEquilibriumPoint);
		}
		else {
			WriteException(
				DynamicalSystem<IzhikevichSilent>::Exceptions::INVALID_PARAMETERS,
			    "The derived Equilibrium Point (%f, %f) appears to be outside the range XRange(%f, %f) and YRange(%f, %f)",
				this->ActualStableEquilibriumPoint.x, this->ActualStableEquilibriumPoint.y,
				GridXSpec[0], GridXSpec[2],
				GridYSpec[0], GridYSpec[2]
			);
		}
	}
	inline GenericPoint<float> simulateTimeStep(const GenericPoint<float> &PointNow) {
		auto uNow = PointNow.x;
		auto vNow = PointNow.y;

		float vNext, uNext;
		vNext = vNow + 0.5f*(vNow * (0.04f*vNow + 5.0f) + 140.0f - uNow) * timeStep;
		vNext = (vNext > -100) ? vNext : -100;
		vNext = vNext + 0.5f*(vNext * (0.04f*vNext + 5.0f) + 140.0f - uNow) * timeStep;
		vNext = (vNext > -100) ? vNext : -100;

		uNext = uNow + (a*(b*vNext - uNow)) * timeStep;

		return GenericPoint<float>(uNext, vNext);
	}
	inline bool isAttracted(const GenericPoint<float> &PointNow) {
		auto XDiff = ActualStableEquilibriumPoint.x - PointNow.x;
		auto YDiff = ActualStableEquilibriumPoint.y - PointNow.y;
		return (std::abs(XDiff) < 0.05f && std::abs(YDiff) < 0.05f);
	}
	inline DiscreteRange getXLims() {
		return this->XRange;
	}
	inline DiscreteRange getYLims() {
		return this->YRange;
	}
};

#endif