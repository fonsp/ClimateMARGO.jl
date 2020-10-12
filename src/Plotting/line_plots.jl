using Plots
using LaTeXStrings
using Colors

# Helpers

function pl_plot_refline!(x, y)
	plot!(x, y, color="rgba(0,0,0,.5)", label=nothing, linestyle=:dash)
end


function pl_fill_between!(x, y1, y2; kwargs...)
	plot!(x, y1, fillrange=[y2, y1]; kwargs...)
end

function pl_fill_past!(model, ylim)
    is_past = (model.domain .<= model.present_year)
    pl_fill_between!(
        model.domain[is_past],
        ones(size(model.domain[is_past])) * ylim[1] * 2.,
        ones(size(model.domain[is_past])) * ylim[2] * 2.,
        facecolor = "b", alpha = 0.1,
		ylim=ylim
    )
end

function pl_finish_years_plot!(model::ClimateModel; when=missing, ylim=nothing, refline=nothing)
	plot!(
		xlabel="year",
		ylim=ylim,
		grid=true,
		xlim=(model.domain[1], 2200.),
		xticks=model.domain[1]:40.:2200.,
    )
	if refline !== nothing
		t = if when === missing
			model.domain
		else
			model.domain[when]
		end
		pl_plot_refline!(t, fill(refline, size(t)))
	end
	if ylim !== nothing
		pl_fill_past!(model, ylim)
	end
	return plot!()
end

# function fill_past(m, ylims)
#     domain_idx = (t(m) .> m.present_year)
#     fill_between(
#         t(m)[.~domain_idx],
#         ones(size(t(m)[.~domain_idx])) * ylims[1] * 2.,
#         ones(size(t(m)[.~domain_idx])) * ylims[2] * 2.,
#         facecolor="b", alpha=0.1
#     )
#     ylim(ylims)
#     return
# end


# Model plots

function pl_plot_emissions(model::ClimateModel)
    data = [
        effective_baseline_emissions(model),
        effective_emissions(model),
	]
    labels = [L"$rq$ (no-policy baseline)" L"$rq(1-M) - q_{0}R$ (controlled)"]
	limit = maximum(effective_baseline_emissions(model))
	ylim = 1.1 .* (-limit, limit)
    plot(
        model.domain,
        data,
		title="Effective emissions",
		ylabel=L"effective CO$_{2e}$ emissions [ppm / yr]",
        label=labels,
    )
	pl_finish_years_plot!(model, ylim=ylim, refline=0.0)
end

# function plot_emissions(m::ClimateModel)
#     title("effective emissions")
#     #fill_past(m, ylims)
#     plot(t(m), zeros(size(t(m))), "k-", alpha=0.9)
#     plot(t(m), effective_emissions(m), linestyle = "--", color="grey", label=L"$rq$ (no-policy baseline)")
#     plot(t(m), effective_emissions(m, M=true), color="C0", label=L"$rq(1-M)$ (controlled)")
#     plot(t(m), effective_emissions(m, M=true, R=true), color="C1", label=L"$rq(1-M) - rq_{0}R$ (controlled)")
#     ylimit = maximum(effective_emissions(m)) * 1.1
#     ylims = [-ylimit, ylimit]
#     ylabel(L"effective CO$_{2e}$ emissions [ppm / yr]")
#     xlim(t(m)[1],2200.)
#     ylim(minimum(effective_emissions(m, M=true, R=true))-5.,1.1*maximum(effective_emissions(m)))
#     xticks(t(m)[1]:40.:2200.)
#     xlabel("year")
#     grid(true)
#     return
# end


function pl_plot_concentrations(model::ClimateModel)
	data = [
		CO₂_baseline(model),
        CO₂(model),
	]
    labels = [L"$c$ (no-policy baseline)" L"$c_{M,R}$ (controlled)"]
	limit = maximum(CO₂_baseline(model))
	ylim = 1.1 .* (0, limit)
    plot(
        model.domain,
        data,
		title="Concentrations",
		ylabel=L"CO$_{2e}$ concentration [ppm]",
        label=labels,
    )
	pl_finish_years_plot!(model, ylim=ylim)
end


# function plot_concentrations(m::ClimateModel)
#     title("concentrations")
#     #fill_past(m, ylims)
#     plot(t(m), c(m), "--", color="gray", label=L"$c$ (no-policy baseline)")
#     plot(t(m), c(m, M=true), color="C0", label=L"$c_{M}$")
#     plot(t(m), c(m, M=true, R=true), color="C1", label=L"$c_{M,R}$")
#     ylims = [0., maximum(c(m))*1.05]
#     ylabel(L"CO$_{2e}$ concentration [ppm]")
#     xlabel("year")
#     xlim(t(m)[1],2200.)
#     ylim(100., 1.05*maximum(c(m)))
#     xticks(t(m)[1]:40.:2200.)
#     grid(true)
#     return
# end



function pl_plot_temperatures(model::ClimateModel; hide_baseline=false)
	if !hide_baseline
		plot(model.domain, δT_baseline(model), color=1, label=L"$T$ (no-policy baseline)")
	else
		plot()
	end
	
	data = [
		δT_no_geoeng(model),
        δT(model),
		δT(model).*sqrt.(1. .- model.controls.adapt),
	]
    labels = [L"$T_{M,R}$ (controlled with $G=0$)" L"$T_{M,R,G}$ (controlled)" L"$T_{M,R,G,A}$ (adapted)"]
	colors = [2 4 3]
	limit = maximum(δT_baseline(model))
	ylim = 1.1 .* (0, limit)
    plot!(
        model.domain,
        data,
		title="Temparature change since 1850",
		ylabel=L"temperature anomaly [$^{\circ}$C]",
        label=labels,
		color=colors,
    )
	pl_finish_years_plot!(model, ylim=ylim, refline=2.0)
end

# function plot_temperatures(m::ClimateModel)
#     title("temperature change since 1850")
#     #fill_past(m, ylims)
#     plot(t(m),2.0.*ones(size(t(m))),"k--", alpha=0.9)
#     plot(t(m),T(m), "--", color="gray", label=L"$T$ (no-policy baseline)")
#     plot(t(m),T(m, M=true), color="C0", label=L"$T_{M}$")
#     plot(t(m),T(m, M=true, R=true), color="C1", label=L"$T_{M,R}$")
#     plot(t(m),T(m, M=true, R=true, G=true), color="C3", label=L"$T_{M,R,G}$")
#     plot(t(m),T(m, M=true, R=true, G=true, A=true), color="C2", label=L"$T_{M,R,G,A}$")
#     ylims = [0., maximum(T(m)) * 1.05]
#     ylabel(L"temperature anomaly [$^{\circ}$C]")
#     xlabel("year")
#     xlim(t(m)[1],2200.)
#     xticks(t(m)[1]:40.:2200.)
#     grid(true)
#     legend()
#     return
# end

function pl_plot_controls(model::ClimateModel)
	
	data = [
		model.controls.mitigate,
        model.controls.remove,
		model.controls.adapt,
		model.controls.geoeng,
	]
	
    labels = [L"$M$ (emissions mitigation)" L"$R$ (carbon dioxide removal)" L"$A$ (adaptation)" L"$G$ (solar geoengineering)"]
    plot(
        model.domain,
        data,
		title="Optimized control deployments",
		ylabel="fractional control deployment",
        label=labels,
    )
	
	pl_finish_years_plot!(model, ylim=(0., 1.))
end

# function plot_controls(m::ClimateModel)
#     title("optimized control deployments")
#     plot(t(m), m.controls.mitigate, color="C0", label=L"$M$ (emissions mitigation)")
#     plot(t(m), m.controls.remove, color="C1", label=L"$R$ (carbon dioxide removal)")
#     plot(t(m), m.controls.adapt, color="C2", label=L"$A$ (adaptation)")
#     plot(t(m), m.controls.geoeng, color="C3", label=L"$G$ (solar geoengineering)")
#     ylims = [0., 1.]
#     ylim([0,1.0])
#     ylabel("fractional control deployment")
#     xlabel("year")
#     xlim(t(m)[1],2200.)
#     xticks(t(m)[1]:40.:2200.)
#     grid(true)
#     return
# end


function pl_plot_benefits(model::ClimateModel; discounted=true)
	discount = if discounted
		discounting(model)
	else
		1.0
	end
	
	when = (model.domain .> model.present_year)
    benefits = (damage_cost_baseline(model) - damage_cost(model))
	
	t = model.domain[when]
	
	plot()
	pl_fill_between!(
		t, 
		zeros(size(t)), 
		((benefits - control_cost(model)) .* discount)[when], 
		fillcolor = "rgba(0,0,0,.15)",
		label=nothing
	)
	
	data = [
        (benefits .* discount)[when],
		(- control_cost(model) .* discount)[when],
		((benefits - control_cost(model)) .* discount)[when],
	]
    labels = [L"$T_{M,R}$ (controlled with $G=0$)" L"$T_{M,R,G}$ (controlled)" L"$T_{M,R,G,A}$ (adapted)"]
	colors = [2 4 3]
    plot!(
        model.domain[when],
        data,
		title="Cost-benefit analysis",
		ylabel=L"discounted costs and benefits [10$^{12}$ \$ / year]",
        label=labels,
		color=colors,
    )
	pl_finish_years_plot!(model, when=when, refline=0.0)
end

# function plot_benefits(m::ClimateModel; discounting=true)
#     domain_idx = (t(m) .> m.domain.present_year)

#     fill_between(
#         t(m)[domain_idx],
#         0 .*ones(size(t(m)))[domain_idx],
#         net_benefit(m, discounting=discounting, M=true, R=true, G=true, A=true)[domain_idx],
#         facecolor="grey", alpha=0.2
#     )
#     plot(t(m)[domain_idx], 0 .*ones(size(t(m)))[domain_idx], "--", color="gray", alpha=0.9, label="no-policy baseline")
#     plot(t(m)[domain_idx], benefit(m, discounting=discounting, M=true, R=true, G=true, A=true)[domain_idx], color="C1", label="benefits (of avoided damages)")
#     plot(t(m)[domain_idx], cost(m, discounting=discounting, M=true, R=true, G=true, A=true)[domain_idx], color="C3", label="costs (of climate controls)")
#     plot(t(m)[domain_idx], net_benefit(m, discounting=discounting, M=true, R=true, G=true, A=true)[domain_idx], color="k", label="net benefits (benefits - costs)")
#     ylabel(L"discounted costs and benefits [10$^{12}$ \$ / year]")
#     xlabel("year")
#     xlim(t(m)[1],2200.)
#     xticks(t(m)[1]:40.:2200.)
#     grid(true)
#     title("cost-benefit analysis")
#     return
# end

function pl_plot_damages(model::ClimateModel; discounted=false, normalized=false)
	discount = if discounted
		deepcopy(discounting(model))
	else
		1.0
	end
    E = if normalized
		deepcopy(model.economics.GWP)/100.
	else
		1.0
	end
	
	when = (model.domain .> model.present_year)
	
	t = model.domain[when]
	
	plot()
	pl_fill_between!(
		t, 
		zeros(size(t)), 
		(control_cost(model) .* discount ./ E)[when], 
		fillcolor = 4,
		#alpha=.2,
		label=nothing
	)
	
	data = [
        (damage_cost_baseline(model) .* discount ./ E)[when],
		(net_cost(model) .* discount ./ E)[when],
		(damage_cost(model) .* discount ./ E)[when],
		(control_cost(model) .* discount ./ E)[when],
	]
    labels = ["uncontrolled damages" "net costs (controlled damages + controls)" "controlled damages" "cost of controls"]
	colors = [1 :black 2 4]
    plot!(
        model.domain[when],
        data,
		title="Costs of avoiding a damage threshold",
		ylabel=L"discounted costs [10$^{12}$ \$ / year]",
        label=labels,
		color=colors,
    )
	plot!(
		t,
		(model.economics.β .* (model.economics.GWP ./ E) .* (2.0^2).*ones(size(model.domain)))[when],
		color="rgba(0,0,0,.5)", 
		label=L"damage threshold at 2$^{\circ}$ C with $A=0$",
		linestyle=:dash
	)
	pl_finish_years_plot!(model)
end

# function plot_damages(m::ClimateModel; discounting=true, percent_GWP=false)
#     Enorm = deepcopy(E(m))/100.
#     if ~percent_GWP; Enorm=1.; end;

#     domain_idx = (t(m) .> m.domain.present_year)
#     fill_between(
#         t(m)[domain_idx],
#         0 .*ones(size(t(m)))[domain_idx],
#         (cost(m, discounting=discounting, M=true, R=true, G=true, A=true) ./ Enorm)[domain_idx],
#         facecolor="C3", alpha=0.2
#     )
#     Tgoal = 2.
#     plot(
#         t(m)[domain_idx],
#         (damage(m.economics.β, E(m), Tgoal, 0., discount=discount(m)) ./ Enorm)[domain_idx],
#         "k--", alpha=0.5, label=L"damage threshold at 2$^{\circ}$ C with $A=0$"
#     )
#     damages = damage(m, discounting=discounting, M=true, R=true, G=true, A=true)
#     costs = cost(m, discounting=discounting, M=true, R=true, G=true, A=true)
#     plot(t(m)[domain_idx], (damage(m, discounting=discounting) ./ Enorm)[domain_idx], color="C0", label="uncontrolled damages")
#     plot(t(m)[domain_idx], ((damages .+ costs)./ Enorm)[domain_idx], color="k", label="net costs (controlled damages + controls)")
#     plot(t(m)[domain_idx], (damages ./ Enorm)[domain_idx], color="C1", label="controlled damages")
#     plot(t(m)[domain_idx], (costs ./ Enorm)[domain_idx], color="C3", label="cost of controls")
#     ylim([0, maximum((damage(m, discounting=discounting) ./ Enorm)[domain_idx]) * 0.75])

#     if ~percent_GWP;
#         if ~discounting;
#             ylabel(L"costs [10$^{12}$ \$ / year]");
#         else;
#             ylabel(L"discounted costs [10$^{12}$ \$ / year]");
#         end
#     else
#         if ~discounting
#             ylabel("costs [% GWP]")
#         else
#             ylabel("discounted costs [% GWP]")
#             print("NOT YET SUPPORTED")
#         end
#     end

#     xlabel("year")
#     xlim(t(m)[1],2200.)
#     xticks(t(m)[1]:40.:2200.)
#     grid(true)
#     title("costs of avoiding a damage threshold")
#     legend()
#     return
# end


# State plot

function pl_plot_state(model::ClimateModel; plot_legends=true)
	plot(
		pl_plot_emissions(model),
		pl_plot_concentrations(model),
		pl_plot_temperatures(model),
		pl_plot_controls(model),
		pl_plot_benefits(model),
		pl_plot_damages(model),
    	layout=(2,3),
		size=(1300,800)
    )
end