import React, { Children, useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import * as zebar from "zebar";

const providers = zebar.createProviderGroup({
	network: { type: "network" },
	glazewm: { type: "glazewm" },
	cpu: { type: "cpu" },
	date: { type: "date", formatting: "EEE, MMM yyyy d, h:mm a" },
	battery: { type: "battery" },
	memory: { type: "memory" },
	weather: { type: "weather" },
	audio: { type: "audio" },
	disk: { type: "disk" },
});

createRoot(document.getElementById("root")).render(<App />);

function App() {
	const [output, setOutput] = useState(providers.outputMap);

	useEffect(() => {
		providers.onOutput(() => setOutput(providers.outputMap));
	}, []);

	// Get icon to show for current network status.
	function getNetworkIcon(networkOutput) {
		switch (networkOutput.defaultInterface?.type) {
			case "ethernet":
				return <i className="nf nf-md-ethernet_cable"></i>;
			case "wifi":
				if (networkOutput.defaultGateway?.signalStrength >= 80) {
					return <i className="nf nf-md-wifi_strength_4"></i>;
				} else if (networkOutput.defaultGateway?.signalStrength >= 65) {
					return <i className="nf nf-md-wifi_strength_3"></i>;
				} else if (networkOutput.defaultGateway?.signalStrength >= 40) {
					return <i className="nf nf-md-wifi_strength_2"></i>;
				} else if (networkOutput.defaultGateway?.signalStrength >= 25) {
					return <i className="nf nf-md-wifi_strength_1"></i>;
				} else {
					return <i className="nf nf-md-wifi_strength_outline"></i>;
				}
			default:
				return <i className="nf nf-md-wifi_strength_off_outline"></i>;
		}
	}

	// Get icon to show for how much of the battery is charged.
	function getBatteryIcon(batteryOutput) {
		let batteryClass = "";
		let batteryIcon;

		if (batteryOutput.chargePercent === 100) {
			batteryClass = " full-battery";
		} else if (batteryOutput.chargePercent <= 20) {
			batteryClass = " low-battery";
		}

		if (batteryOutput.chargePercent > 90)
			batteryIcon = (
				<i className={`nf nf-fa-battery_4${batteryClass}`}></i>
			);
		else if (batteryOutput.chargePercent > 70)
			batteryIcon = (
				<i className={`nf nf-fa-battery_3${batteryClass}`}></i>
			);
		else if (batteryOutput.chargePercent > 40)
			batteryIcon = (
				<i className={`nf nf-fa-battery_2${batteryClass}`}></i>
			);
		else if (batteryOutput.chargePercent > 20)
			batteryIcon = (
				<i className={`nf nf-fa-battery_1${batteryClass}`}></i>
			);
		else
			batteryIcon = (
				<i className={`nf nf-fa-battery_0${batteryClass}`}></i>
			);

		if (batteryOutput.isCharging) {
			return (
				<>
					<i className="nf nf-md-power_plug charging"></i>
					{batteryIcon}
				</>
			);
		}

		return batteryIcon;
	}

	// Get icon to show for current weather status.
	function getWeatherIcon(weatherOutput) {
		switch (weatherOutput.status) {
			case "clear_day":
				return <i className="nf nf-weather-day_sunny"></i>;
			case "clear_night":
				return <i className="nf nf-weather-night_clear"></i>;
			case "cloudy_day":
				return <i className="nf nf-weather-day_cloudy"></i>;
			case "cloudy_night":
				return <i className="nf nf-weather-night_alt_cloudy"></i>;
			case "light_rain_day":
				return <i className="nf nf-weather-day_sprinkle"></i>;
			case "light_rain_night":
				return <i className="nf nf-weather-night_alt_sprinkle"></i>;
			case "heavy_rain_day":
				return <i className="nf nf-weather-day_rain"></i>;
			case "heavy_rain_night":
				return <i className="nf nf-weather-night_alt_rain"></i>;
			case "snow_day":
				return <i className="nf nf-weather-day_snow"></i>;
			case "snow_night":
				return <i className="nf nf-weather-night_alt_snow"></i>;
			case "thunder_day":
				return <i className="nf nf-weather-day_lightning"></i>;
			case "thunder_night":
				return <i className="nf nf-weather-night_alt_lightning"></i>;
		}
	}

	function getAudioIcon(audioOutput) {
		const volume = Math.round(
			audioOutput.defaultPlaybackDevice?.volume ?? 0,
		);
		if (volume === 0) {
			return <i className="nf nf-fa-volume_off"></i>;
		} else if (volume <= 33) {
			return <i className="nf nf-fa-volume_down"></i>;
		} else if (volume <= 66) {
			return <i className="nf nf-md-volume_medium"></i>;
		} else {
			return <i className="nf nf-fa-volume_up"></i>;
		}
	}

	function getDiskUsagePercent(diskOutput) {
		if (!diskOutput?.disks?.length) return 0;
		const totalSpace = diskOutput.disks.reduce(
			(sum, disk) => sum + disk.totalSpace.bytes,
			0,
		);
		const totalUsed = diskOutput.disks.reduce(
			(sum, disk) =>
				sum + (disk.totalSpace.bytes - disk.availableSpace.bytes),
			0,
		);
		return totalSpace > 0 ? Math.round((totalUsed / totalSpace) * 100) : 0;
	}

	return (
		<div className="app">
			<div className="left">
				<i className="logo nf nf-fa-windows"></i>
				{output.glazewm && (
					<div className="workspaces">
						{output.glazewm.currentWorkspaces.map((workspace) => (
							<button
								className={`workspace ${
									workspace.hasFocus && "focused"
								} ${workspace.isDisplayed && "displayed"}`}
								onClick={() =>
									output.glazewm.runCommand(
										`focus --workspace ${workspace.name}`,
									)
								}
								key={workspace.name}
							>
								{workspace.displayName ?? workspace.name}
							</button>
						))}
					</div>
				)}
			</div>

			<div className="center">
				<span className="date">{output.date?.formatted}</span>
				{output.glazewm?.focusedContainer?.processName && (
					<>
						<span className="separator">•</span>
						<span className="process">
							{output.glazewm?.focusedContainer?.processName}
						</span>
					</>
				)}
			</div>

			<div className="right">
				<div className="status-box">
					{output.glazewm && (
						<>
							{output.glazewm.isPaused && (
								<button
									className="paused-button"
									onClick={() =>
										glazewm.runCommand("wm-toggle-pause")
									}
								>
									PAUSED
								</button>
							)}
							{output.glazewm.bindingModes.map((bindingMode) => (
								<button
									className="binding-mode"
									key={bindingMode.name}
									onClick={() =>
										output.glazewm.runCommand(
											`wm-disable-binding-mode --name ${bindingMode.name}`,
										)
									}
								>
									{bindingMode.displayName ??
										bindingMode.name}
								</button>
							))}

							<button
								className={`tiling-direction nf ${
									output.glazewm.tilingDirection ===
									"horizontal"
										? "nf-md-swap_horizontal"
										: "nf-md-swap_vertical"
								}`}
								onClick={() =>
									output.glazewm.runCommand(
										"toggle-tiling-direction",
									)
								}
							></button>
						</>
					)}

					{output.network && (
						<div className="network">
							{getNetworkIcon(output.network)}
							{output.network.defaultGateway?.ssid}
							<span className="traffic">
								<span className="download">
									↓{output.network.traffic?.received?.siValue}
									{output.network.traffic?.received?.siUnit}
								</span>
								<span className="upload">
									↑
									{
										output.network.traffic?.transmitted
											?.siValue
									}
									{
										output.network.traffic?.transmitted
											?.siUnit
									}
								</span>
							</span>
						</div>
					)}

					{output.memory && (
						<div className="memory">
							<i className="nf nf-fae-chip"></i>
							{Math.round(output.memory.usage)}%
						</div>
					)}

					{output.cpu && (
						<div className="cpu">
							<i className="nf nf-oct-cpu"></i>
							<span
								className={
									output.cpu.usage > 85 ? "high-usage" : ""
								}
							>
								{Math.round(output.cpu.usage)}%
							</span>
						</div>
					)}

					{output.battery && (
						<div className="battery">
							{getBatteryIcon(output.battery)}
							{Math.round(output.battery.chargePercent)}%
						</div>
					)}

					{output.audio && (
						<div className="audio">
							{getAudioIcon(output.audio)}
							<span
								className={
									Math.round(
										output.audio.defaultPlaybackDevice
											?.volume ?? 0,
									) === 0
										? "muted"
										: ""
								}
							>
								{Math.round(
									output.audio.defaultPlaybackDevice
										?.volume ?? 0,
								)}
								%
							</span>
						</div>
					)}

					{output.disk && (
						<div className="disk">
							<i className="nf nf-fa-hdd_o"></i>
							<span
								className={
									getDiskUsagePercent(output.disk) > 85
										? "high-usage"
										: ""
								}
							>
								{getDiskUsagePercent(output.disk)}%
							</span>
						</div>
					)}

					{output.weather && (
						<div className="weather">
							{getWeatherIcon(output.weather)}
							{Math.round(output.weather.celsiusTemp)}°C
						</div>
					)}
				</div>
			</div>
		</div>
	);
}
